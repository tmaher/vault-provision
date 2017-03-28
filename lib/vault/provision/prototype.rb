# prototype for the individual hierarchy paths
class Vault::Provision::Prototype
  def initialize boss
    @vault = boss.vault
    @instance_dir = boss.instance_dir
    @intermediate_issuer = boss.intermediate_issuer
  end

  def repo_prefix
    ActiveSupport::Inflector.underscore(self.class.to_s)
                            .split('/')[2..-1].join('/')
  end

  def repo_path
    "#{@instance_dir}/#{repo_prefix}"
  end

  def repo_files
    Find.find(repo_path).select { |rf| rf.end_with?('.json') }
  end

  def provision!
    puts "#{self.class} says: Go climb a tree!"
  end
end
