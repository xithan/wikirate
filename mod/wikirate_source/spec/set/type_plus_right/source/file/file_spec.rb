describe Card::Set::TypePlusRight::Source::File::File do
  describe "while editing a file source" do
    before do
      login_as "joe_user"
    end
    it "rejects updating a file source" do
      file1 = File.new File.expand_path("../file1.txt", __FILE__)
      file2 = File.new File.expand_path("../file2.txt", __FILE__)

      source = create_source file: file1
      source_file = Card["#{source.name}+File"]
      source_file.update_attributes file: file2

      expect(source_file.errors).to have_key(:file)
      expect(source_file.errors[:file]).to include("is not allowed to be changed.")
    end
  end
end
