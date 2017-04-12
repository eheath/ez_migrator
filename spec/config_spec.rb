require 'spec_helper'

describe EzMigrator::Config do
  it "configures" do
    config = EzMigrator::Config.new({env: 'test', file_name: 'config.yml'})
    expect(config.env).to eq('test')
  end

end