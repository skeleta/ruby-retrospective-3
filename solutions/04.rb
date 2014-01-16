module Asm
  module Instructions
    def mov(register, value)
      add_instruction
      proc = Proc.new { |actual_value| @registers[register] = actual_value }
      @operations << [value, proc, :instruction]
    end

    def inc(register, value=1)
      add_instruction
      proc = Proc.new { |actual_value| @registers[register] += actual_value }
      @operations << [value, proc, :instruction]
    end

    def dec(register, value=1)
      add_instruction
      proc = Proc.new { |actual_value| @registers[register] -= actual_value }
      @operations << [value, proc, :instruction]
    end

    def cmp(register, value)
      add_instruction
      proc = Proc.new { |actual_value| @cmp_value = @registers[register] - actual_value }
      @operations << [value, proc, :instruction]
    end

    def self.add_instruction
      @pointer[@operations.length] = @instructions_number
      @instructions_number += 1
    end

    def label(label)
      @labels[label] = @instructions_number
    end
  end

  module Jumps
    def add_instruction
      @pointer[@operations.length] = @instructions_number
      @instructions_number += 1
    end

    def jmp(where)
      add_instruction
      @operations << where
    end

    def je(where)
      add_instruction
      @operations << [where, Proc.new { @cmp_value == 0}]
    end

    def jne(where)
      add_instruction
      @operations << [where, Proc.new { @cmp_value != 0}]
    end

    def jl(where)
      add_instruction
      @operations << [where, Proc.new { @cmp_value < 0}]
    end

    def jle(where)
      add_instruction
      @operations << [where, Proc.new { @cmp_value <= 0}]
    end

    def jg(where)
      add_instruction
      @operations << [where, Proc.new { @cmp_value > 0}]
    end

    def jge(where)
      add_instruction
      @operations << [where, Proc.new { @cmp_value >= 0}]
    end
  end

  class CentralProcessingUnit

    include Instructions
    include Jumps

    def initialize
      @instructions_number = 0
      @operations = []
      @pointer = {}
      @labels = {}
      @cmp_value = 0
      @registers = {ax: 0, bx: 0, cx: 0, dx: 0}
    end

    def execute_instructions
      index = 0

      while index < @operations.length do
        if @operations[index].is_a? Array and @operations[index].last == :instruction
          value = calculate_value @operations[index]
          @operations[index][1].call value
          index += 1
        else
          index = jumper(@operations[index], index)
        end
      end

      @registers.values
    end

    private

    def method_missing(method_name)
      method_name
    end

    def check_index(index)
      index ? index : @operations.length
    end

    def conditional_jumper(jump, index)
      if jump.last.call
        where = jump.first.is_a?(Symbol) ? @labels[jump.first] : jump.first
        check_index @pointer.select { |key,value| value == where }.keys.first
      else
        index += 1
      end
    end

    def jumper(jump_operation, index)
      if jump_operation.is_a? Array
        conditional_jumper(jump_operation, index)
      else
        where = jump_operation.is_a?(Symbol) ? @labels[jump_operation] : jump_operation
        check_index @pointer.select { |key,value| value == where }.keys.first
      end
    end

    def calculate_value(operations)
      operations[0].is_a?(Symbol) ? @registers[operations[0]] : operations[0]
    end
  end

  def self.asm(&block)
    asm = CentralProcessingUnit.new
    asm.instance_eval &block
    asm.execute_instructions
  end
end

Asm.asm do
  mov ax, 40
  mov bx, 32
  label cycle
  cmp ax, bx
  je finish
  jl asmaller
  dec ax, bx
  jmp cycle
  label asmaller
  dec bx, ax
  jmp cycle
  label finish
end