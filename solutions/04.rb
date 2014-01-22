module Asm
  module Instructions

    operations = {
      mov: proc { |regs, register, value|   regs[register] = value },
      inc: proc { |regs, register, value=1| regs[register] += value },
      dec: proc { |regs, register, value=1| regs[register] -= value },
      cmp: proc { |regs, register, value|   regs[:cmp] = (regs[register] <=> value) },
      jmp: proc { |regs| true },
      je:  proc { |regs| regs[:cmp] == 0 },
      jne: proc { |regs| regs[:cmp] != 0 },
      jl:  proc { |regs| regs[:cmp] < 0  },
      jle: proc { |regs| regs[:cmp] <= 0 },
      jg:  proc { |regs| regs[:cmp] > 0  },
      jge: proc { |regs| regs[:cmp] >= 0 },
    }

    operations.each do |operation_name, operation|
      define_method operation_name do |*args|
        @operations << [operation, @registers, operation_name, args]
      end
    end

    def label(label)
      @labels[label] = @operations.length
    end
  end

  class CentralProcessingUnit

    include Instructions

    def initialize
      @operations = []
      @labels = {}
      @registers = {ax: 0, bx: 0, cx: 0, dx: 0, cmp: 0}
    end

    def execute_instructions
      index = 0

      while index < @operations.length do
        # p index
        if [:mov, :inc, :dec, :cmp].include? @operations[index][2]
          args = evaluate(@operations[index].last)
          @operations[index].first.call(@operations[index][1], *args)
          index += 1
        else
          index = jumper(@operations[index], index)
          # p index
        end
      end

      @registers.values[0..-2]
    end

    private

    def method_missing(method_name)
      method_name
    end

    def evaluate(args)
      if args.length == 2
        [args.first, (@registers[args.last] or args.last)]
      else
        args
      end
    end

    def jumper(jump_operation, index)
      where = (@labels[jump_operation.last.first] or jump_operation.last.first)
      jump_operation.first.call(jump_operation[1]) ? where : index + 1
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