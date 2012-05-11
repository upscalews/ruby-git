class Git::Blame
  attr_reader :result

  def initialize(base, file, opts={})
    @base = base
    @file = file
    @options = opts

    @result = run_blame
  end

  private

  def run_blame
    lines = @base.lib.blame(@file, @options)
    result = Git::BlameResult.new(@base)
    lines.each do |line|
      words = line.split(/\s+/)
      next unless words.first.length == 40 #TODO this breaks if git ever introduces a 40-character attribute name
      ref = words[0]
      block_start = words[2].to_i
      block_length = words[3].to_i
      result.add_block ref, block_start, block_length
    end
    result
  end
end

class Git::BlameResult
  delegate :[], :each, :each_with_index, to: :lines

  def initialize(base)
    @base = base
    @commit_cache = {}
    @lines = []
  end

  def add_block(ref, start, length)
    commit = (@commit_cache[ref] ||= @base.object(ref))
    length.times { |i| @lines[start + i] = commit }
    commit
  end

  attr_reader :lines
  private :lines
end
