# for rubocop, this comment is a matter of policy
class Vault::Provision::Sys::Policy < Vault::Provision::Prototype
  def repo_files
    Find.find(repo_path).select { |rf| rf.end_with?('.json', '.hcl') }
  end

  def provision!
    repo_files.each do |rf|
      policy_name = if rf.end_with? '.json'
                      File.basename(rf, '.json')
                    elsif rf.end_with? '.hcl'
                      File.basename(rf, '.hcl')
                    end
      next if Vault::Provision::SYSTEM_POLICIES.include? policy_name
      @vault.sys.put_policy(policy_name, File.read(rf))
    end
  end
end
