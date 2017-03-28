require 'spec_helper'

describe Vault::Provision do
  it "has a cubbyhole" do
    expect(client.sys.mounts[:cubbyhole].description).to \
      include 'per-token private secret storage'
  end

  #it "has a pki-root mount" do
  #  expect(client.sys.mounts).to include 'pki-root'
  #end
end
