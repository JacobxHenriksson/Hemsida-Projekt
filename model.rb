module Model
    
    def getdb
        db = SQLite3::Database.new("db/db.db")
        db.results_as_hash = true
        return db   
    end

    def validator(name)
        if name == ""
            flash[:notice] = "You can't write that"
            redirect('/register')
        end

        if name.include?("å") || name.include?("ä") || name.include?("ö")
            flash[:notice] = "You can't write that"
            redirect('/register')
        end
    end

end