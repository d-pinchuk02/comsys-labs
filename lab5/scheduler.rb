Task = Struct.new(:id, :operation, :level, :dependencies, :processor, :start_time, :end_time)

class Scheduler
  def initialize
    @processors = {
      '+' => ['ADD1', 'ADD2'],
      '-' => ['SUB1', 'SUB2'],
      '*' => ['MUL1'],
      '/' => ['DIV1']
    }
    
    @execution_times = {
      '+' => 1,
      '-' => 1,
      '*' => 2,
      '/' => 3
    }
    
    @tasks = []
    @task_counter = 0
  end

  def schedule_expression(tree)
    if tree.nil? || is_leaf?(tree)
      puts "Не можна побудувати граф завдань: вираз не містить операцій"
      return
    end

    build_task_graph(tree)

    if @tasks.empty?
      puts "У виразі не знайдено операцій"
      return
    end

    group_tasks_by_level
    distribute_tasks
    visualize_gantt_chart
    calculate_metrics
  end

  private

  def is_leaf?(node)
    node.left.nil? && node.right.nil?
  end

  def build_task_graph(node, level = 0)
    return nil if node.nil? || is_leaf?(node)

    left_task = build_task_graph(node.left, level + 1)
    right_task = build_task_graph(node.right, level + 1)

    dependencies = []
    dependencies << left_task.id if left_task
    dependencies << right_task.id if right_task

    @task_counter += 1
    task = Task.new(
      @task_counter,
      node.value,
      level,
      dependencies,
      nil,
      0,
      0
    )

    @tasks << task
    task
  end

  def group_tasks_by_level
    tasks_by_level = @tasks.group_by(&:level).sort.to_h

    puts "Завдання згруповані за рівнями:".cyan.bold
    tasks_by_level.each do |level, tasks|
      ops = tasks.map(&:operation).join(', ')
      puts "Рівень #{level}: #{ops}"
    end
    puts "-" * 50
  end

  def distribute_tasks
    processor_status = {}
    @processors.values.flatten.each { |proc| processor_status[proc] = 0 }

    sorted_tasks = @tasks.sort_by { |task| [task.dependencies.size, -task.level] }
    sorted_tasks.each do |task|
      available_processors = @processors[task.operation]

      dependency_end_time = 0
      task.dependencies.each do |dep_id|
        dep_task = @tasks.find { |t| t.id == dep_id }
        if dep_task && dep_task.end_time > 0
          dependency_end_time = [dependency_end_time, dep_task.end_time].max + 1
        end
      end

      best_processor = nil
      earliest_start = Float::INFINITY

      available_processors.each do |proc|
        possible_start = [processor_status[proc], dependency_end_time].max
        if possible_start < earliest_start
          earliest_start = possible_start
          best_processor = proc
        end
      end

      start_time = earliest_start
      end_time = start_time + @execution_times[task.operation]

      task.processor = best_processor
      task.start_time = start_time
      task.end_time = end_time

      processor_status[best_processor] = end_time
    end
  end

  def calculate_metrics
    sequential_time = @tasks.sum { |task| @execution_times[task.operation] }
    parallel_time = @tasks.map(&:end_time).max
    active_processors = @tasks.map(&:processor).uniq
    num_active_processors = active_processors.size
    total_processors = @processors.values.flatten.size
    speedup = sequential_time.to_f / parallel_time
    efficiency_active = speedup / num_active_processors
    efficiency_total = speedup / total_processors

    puts "-" * 50
    puts "Метрики продуктивності:".cyan.bold
    puts "Час послідовного обчислення: #{sequential_time} циклів"
    puts "Час паралельного обчислення: #{parallel_time} циклів"
    puts "Коефіцієнт прискорення: #{speedup.round(2)}"
    puts "Кількість активних процесорів: #{num_active_processors}"
    puts "Загальна кількість процесорів: #{total_processors}"
    puts "Ефективність (активні процесори): #{(efficiency_active * 100).round(2)}%"
    puts "Ефективність (всі процесори): #{(efficiency_total * 100).round(2)}%"
    puts "Використані процесори: #{active_processors.join(', ')}"
  end

  def visualize_gantt_chart
    puts "Графік завдань:".cyan.bold
    puts "Завдання | Процесор | Операція | Початок | Кінець | Залежності"
    puts "-" * 65
    
    @tasks.sort_by(&:start_time).each do |task|
      deps = task.dependencies.empty? ? "немає" : task.dependencies.join(",")
      printf("T%-7d | %-8s | %-8s | %-7d | %-6d | %s\n", 
             task.id, task.processor, task.operation, 
             task.start_time, task.end_time, deps)
    end

    puts "-" * 65
    puts "Діаграма Ганта:".cyan.bold
    max_time = @tasks.map(&:end_time).max
    active_processors = @tasks.map(&:processor).uniq.sort

    print "Процесор".ljust(10).concat("| ")
    (0...max_time).each { |t| print "#{t}".center(3) }
    puts ""

    print "".ljust(12, "-")
    (0...max_time).each { print "---" }
    puts ""

    active_processors.each do |processor|
      print processor.ljust(10).concat("| ")

      processor_tasks = @tasks.select { |t| t.processor == processor }.sort_by(&:start_time)
      timeline = Array.new(max_time, "   ")

      processor_tasks.each do |task|
        (task.start_time...task.end_time).each do |time_slot|
          timeline[time_slot] = "T#{task.id}".center(3)
        end
      end

      timeline.each { |slot| print slot }
      puts ""
    end
  end
end