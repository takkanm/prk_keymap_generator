# frozen_string_literal: true

require_relative "prk_keymap_generator/version"

module PrkKeymapGenerator
  class Command
    class RetryError < RuntimeError; end

    PINS = {
      'D1' => 2,
      'D0' => 3,
      'D4' => 4,
      'C6' => 5,
      'D7' => 6,
      'E6' => 7,
      'B4' => 8,
      'B5' => 9,
      'F4' => 29,
      'F5' => 28,
      'F6' => 27,
      'F7' => 26,
      'B1' => 22,
      'B3' => 20,
      'B2' => 23,
      'B6' => 21,
    }
    PADDING_KEY = 'KC_NO'

    def execute!
      collect_split
      collect_init_pins
      collect_layer
      generate
    end

    def collect_split
        print 'Is split keyboard? [y/N] : '
        yes_or_no = gets.strip
        @is_split = false

        case yes_or_no
        when ?y, ?Y, 'Yes', 'YES'
          @is_split = true
        when ?n, ?N, 'No', 'NO'
          @is_split = false
        else
          raise RetryError
        end
    rescue RetryError
      retry
    end

    def collect_init_pins
      @row_pins = []
      @col_pins = []

      print 'MATRIX_ROW_PINS in config.h : '
      row_pins = gets
      row_pins.split(',').each do |pin|
        @row_pins << PINS[pin.strip]
      end

      print 'MATRIX_COL_PINS in config.h : '
      col_pins = gets
      col_pins.split(',').each do |pin|
        @col_pins << PINS[pin.strip]
      end
    end

    def collect_layer
      @layers = {}

      loop do
        print 'add layer ? [y/N] : '
        answer = gets.strip
        case answer
        when ?y, ?Y
          # NOP
        when ?n, ?N
          break
        else
          redo
        end

        print 'layer name: '
        layer_name = gets.strip

        rows = []
        loop do
          print 'add Row or n(o) : '
          row_or_no = gets.strip
          case row_or_no
          when ?n, ?N, 'no', 'No', 'NO'
            break
          else
            rows << row_or_no.split(',').map(&:strip).compact
          end
        end
        max_col_size = rows.map(&:size).max

        rows.each do |row|
          next if row.size == max_col_size
          diff = max_col_size - row.size

          front_padding = [PADDING_KEY] * (diff / 2)
          back_padding  = [PADDING_KEY] * (diff / 2)
          back_padding << PADDING_KEY if diff.odd?

          row.unshift *front_padding
          row.push    *back_padding
        end
        @layers[layer_name] = rows
      end
    end

    def generate
      # TODO: ERB
      File.open('keymap.rb', 'w') do |fp|
        fp.puts <<~EOS
          while !$mutex
            relinquish
          end

          kbd = Keyboard.new

          kbd.split = #{@is_split}

          kbd.init_pins(
            [ #{@row_pins.join(', ')} ],
            [ #{@col_pins.join(', ')} ]
          )

        EOS

        @layers.each do |layer_name, rows|
          fp.puts "kbd.add_layer :#{layer_name}, %i["
          rows.each do |row|
            fp.puts "  #{row.join(' ')}"
          end
          fp.puts ']'
          fp.puts 
        end

        another_layers = @layers.keys[1..-1]
        another_layers.each do |layer_name|
          fp.puts "kbd.define_mod_key :#{layer_name.upcase}, [ :KC_NO, :#{layer_name}, 120, 150 ]" 
        end

        fp.puts <<~EOF

          kbd.start!
        EOF
      end
      puts 'finish!'
    end
  end
end
