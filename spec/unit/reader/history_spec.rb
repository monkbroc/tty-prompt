# encoding: utf-8

RSpec.describe TTY::Prompt::Reader::History do
  it "has no lines" do
    history = described_class.new
    expect(history.size).to eq(0)
  end

  it "defaults maximum size" do
    history = described_class.new
    expect(history.max_size).to eq(512)
  end

  it "presents string representation" do
    history = described_class.new
    expect(history.to_s).to eq("[]")
  end

  it "adds items to history without overflowing" do
    history = described_class.new(3)
    history << "line #1"
    history << "line #2"
    history << "line #3"
    history << "line #4"

    expect(history.to_a).to eq(["line #2", "line #3", "line #4"])
    expect(history.index).to eq(2)
  end

  it "excludes items" do
    exclude = proc { |line| /line #[23]/.match(line) }
    history = described_class.new(3, exclude: exclude)
    history << "line #1"
    history << "line #2"
    history << "line #3"

    expect(history.to_a).to eq(["line #1"])
    expect(history.index).to eq(0)
  end

  it "allows duplicates" do
    history = described_class.new(3)
    history << "line #1"
    history << "line #1"
    history << "line #1"

    expect(history.to_a).to eq(["line #1", "line #1", "line #1"])
  end

  it "prevents duplicates" do
    history = described_class.new(3, duplicates: false)
    history << "line #1"
    history << "line #1"
    history << "line #1"

    expect(history.to_a).to eq(["line #1"])
  end

  it "navigates through history buffer without cycling" do
    history = described_class.new(3)
    history << "line #1"
    history << "line #2"
    history << "line #3"

    expect(history.index).to eq(2)
    history.previous
    history.previous
    expect(history.index).to eq(0)
    history.previous
    expect(history.index).to eq(0)
    history.next
    history.next
    expect(history.index).to eq(2)
    history.next
    expect(history.index).to eq(2)
  end

  it "navigates through history buffer with cycling" do
    history = described_class.new(3, cycle: true)
    history << "line #1"
    history << "line #2"
    history << "line #3"

    expect(history.index).to eq(2)
    history.previous
    history.previous
    expect(history.index).to eq(0)
    history.previous
    expect(history.index).to eq(2)
    history.next
    history.next
    expect(history.index).to eq(1)
    history.next
    expect(history.index).to eq(2)
  end

  it "retrieves current line" do
    history = described_class.new(3, cycle: true)
    expect(history.pop).to eq(nil)

    history << "line #1"
    history << "line #2"
    history << "line #3"

    expect(history.pop).to eq("line #3")
    history.previous
    history.previous
    expect(history.pop).to eq("line #1")
    history.next
    expect(history.pop).to eq("line #2")
  end
end
