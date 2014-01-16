require 'set'

class TodoList
  attr_reader :task

  def initialize(task)
    @task = task
  end

  def self.parse(text)
    list = []

    text.lines do |line|
      # puts line.gsub(/\s+/, " ").scan(/[^\|]+/)[3]
      list << (Task.new *(allocate line.strip.gsub(/\s+/, " ").split(" | ")))
    end

    new list
  end

  def self.allocate(task)
    tags = task[3] ? task[3].split(", ") : []

    return task[0].downcase.to_sym, task[1],
           task[2].downcase.chomp(" |").to_sym, tags
  end

  def filter(criteria)
    TodoList.new @task.select { |task| criteria.compare? task }
  end

  def adjoin(todo_list)
    adjoined = (@task + todo_list.task).uniq
    TodoList.new adjoined
  end

  def tasks_todo
    filter(Criteria.status(:todo)).task.length
  end

  def tasks_in_progress
    filter(Criteria.status(:current)).task.length
  end

  def tasks_completed
    filter(Criteria.status(:done)).task.length
  end

  def completed?
    filter(Criteria.status(:done)).task.length == task.length
  end

  include Enumerable

  def each(&block)
    @task.each(&block)
  end
end

class Task
  attr_reader :status, :description, :priority, :tags

  def initialize(status, description, priority, tags)
    @tags        = tags
    @status      = status.to_sym
    @priority    = priority.to_sym
    @description = description
  end
end

module Criteria
  def self.status(status)
    Pattern.new { |task| task.status == status }
  end

  def self.description(description)
    Pattern.new { |task| task.description == description }
  end

  def self.priority(priority)
    Pattern.new { |task| task.priority == priority }
  end

  def self.tags(tags)
    Pattern.new { |task| Set[*tags] <= Set[*task.tags] }
  end

  class Pattern
    def initialize(&block)
      @filter = block
    end

    def compare?(task)
      @filter.call task
    end

    def &(other)
      Pattern.new { |task| compare?(task) and other.compare?(task) }
    end

    def |(other)
      Pattern.new { |task| compare?(task) or other.compare?(task) }
    end

    def !
      Pattern.new { |task| not compare?(task) }
    end
  end
end
  # class Criterion
  #   def &(other)
  #     Conjunction.new self, other
  #   end

  #   def |(other)
  #     Disjunction.new self, other
  #   end

  #   def !
  #     Negation.new self
  #   end
  # end

  # def self.status(status)
  #   StatusMatches.new status
  # end

  # def self.description(description)
  #   DescriptiontMatches.new description
  # end

  # def self.priority(priority)
  #   PriorityMatches.new priority
  # end

  # def self.tags(tags)
  #   TagsMatches.new tags
  # end

  # class Conjunction < Criterion
  #   def initialize(left, right)
  #     @left  = left
  #     @right = right
  #   end

  #   def compare?(task)
  #     @left.compare?(task) and @right.compare?(task)
  #   end
  # end

  # class Disjunction < Criterion
  #   def initialize(left, right)
  #     @left  = left
  #     @right = right
  #   end

  #   def compare?(task)
  #     @left.compare?(task) or @right.compare?(task)
  #   end
  # end

  # class Negation < Criterion
  #   def initialize(criterion)
  #     @criterion = criterion
  #   end

  #   def compare?(task)
  #     not @criterion.met_by?(task)
  #   end
  # end

  # class StatusMatches < Criterion
  #   def initialize(status)
  #     @status = status
  #   end

  #   def compare?(task)
  #     task.status == @status
  #   end
  # end

  # class DescriptiontMatches < Criterion
  #   def initialize(description)
  #     @description = description
  #   end

  #   def compare?(task)
  #       task.description == @description
  #   end
  # end

  # class PriorityMatches < Criterion
  #   def initialize(priority)
  #     @priority = priority
  #   end

  #   def compare?(task)
  #     task.priority == @priority
  #   end
  # end

  # class TagsMatches < Criterion
  #   def initialize(tags)
  #     @tags = tags
  #   end

  #   def compare?(task)
  #     subset  = Set[*@tags]
  #     big_set = Set[*task.tags]

  #     subset.subset? big_set
  #   end
  # end
# end

text = "TODO    | Eat spaghetti.               | High   | food, happiness
        TODO    | Get 8 hours of sleep.        | Low    | health
        CURRENT | Party animal.                | Normal | socialization
        CURRENT | Grok Ruby.                   | High   | development, ruby
        DONE    | Have some tea.               | Normal |
        TODO    | Destroy Facebook and Google. | High   | save humanity, conspiracy
        TODO    | Hunt saber-toothed cats.     | Low    | wtf
        DONE    | Do the 5th Ruby challenge.   | High   | ruby course, FMI, development, ruby
        TODO    | Find missing socks.          | Low    |
        CURRENT | Grow epic mustache.          | High   | sex appeal"
a = TodoList.parse(text)
a.tasks_in_progress
a.tasks_todo
a.tasks_completed
a.completed?
b = a.filter Criteria.status(:done) | Criteria.status(:current)
b.task.each {|task| puts task.description}