require 'evernote'

class Importer

  #EVERNOTE_ENV = 'sandbox'
  EVERNOTE_ENV = 'live'

  def initialize
    
  end

  class NoteStore

    def initialize(uri, thrift_client_options = {})
      @client = Evernote::Client.new(Evernote::EDAM::NoteStore::NoteStore::Client, uri, thrift_client_options)
    end

    def method_missing(name, *args, &block)
      @client.send(name, *args, &block)
    end

  end

  def connect
    auth_file = File.expand_path("/Users/wsargent/work/evernote-import/evernote.yml")
    auth_env = EVERNOTE_ENV
    evernote_host = if EVERNOTE_ENV == 'live'
                      "www.evernote.com"
                    else
                      "sandbox.evernote.com"
                    end

    user_url = "https://#{evernote_host}/edam/user"
    @user_store = Evernote::UserStore.new(user_url, auth_file, auth_env)
    auth_result = @user_store.authenticate

    shard_id = auth_result.user.shardId
    note_url = "http://#{evernote_host}/edam/note/#{shard_id}"
    @note_store = NoteStore.new(note_url)

    @auth_token = auth_result.authenticationToken
  end

  def auth_token
    @auth_token
  end

  def note_store
    @note_store
  end

  def user_store
    @user_store
  end

  def find_notebook
    notebooks = note_store.listNotebooks(auth_token)
    notebook = notebooks.find { |nb| nb.name =~ /Goals/}
    notebook
  end

  def create_note(title, content, created_timestamp, notebook)
    note = Evernote::EDAM::Type::Note.new
    note.title = title
    note.content = wrap_content(content)
    note.notebookGuid = notebook.guid
    note.created = created_timestamp

    puts "create_note: node = #{note.inspect}"

    begin
      note_store.createNote(auth_token, note)
    rescue Evernote::EDAM::Error::EDAMUserException => e
      puts "create_note: e = #{e.inspect} for note #{note.inspect}"
    end
  end

  def wrap_content(content)    
    <<-HERE
      <!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml.dtd\">
      <en-note>#{content}</en-note>
    HERE
  end


end
