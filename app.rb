require 'sinatra'
require 'slim'
require 'sqlite3'
require 'sinatra/reloader'
require 'bcrypt'
require 'sinatra/flash'
enable :sessions

get('/')  do
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    @result = db.execute("SELECT * FROM champions ORDER BY Name ASC")
    p session[:id], session[:currentuser], session[:permissions]
    slim(:champions)
end 

post('/champion') do
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    name = params[:name]
    item1 = params[:item1]
    item2 = params[:item2]
    item3 = params[:item3]
    item4 = params[:item4]
    item5 = params[:item5]
    item6 = params[:item6]
    db.execute("INSERT INTO champions (Name, Item1, Item2, Item3, Item4, Item5, Item6) VALUES (?, ?, ?, ?, ?, ?, ?)", name, item1, item2, item3, item4, item5, item6)
    redirect('/')
end

get('/champions/new') do
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    @items = db.execute("SELECT * FROM items")
    slim(:"/add_champion")
end

post('/champions/:id/delete') do
    id = params[:id].to_i
    db = SQLite3::Database.new("db/db.db")
    db.execute("DELETE FROM champions WHERE Cahmpion_Id = ?",id)
    redirect('/')
end

get('/champions/edit/:id') do
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    @items = db.execute("SELECT * FROM items")
    @champId = params[:id]
    slim(:"/edit_build")
end

post('/champion_build') do
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    item1 = params[:item1]
    item2 = params[:item2]
    item3 = params[:item3]
    item4 = params[:item4]
    item5 = params[:item5]
    item6 = params[:item6]
    champId = params[:champId].to_i
    p champId
    db.execute("UPDATE champions SET Item1 = ?, Item2 = ?, Item3 = ?, Item4 = ?, Item5 = ?, Item6 = ? WHERE Cahmpion_Id = ?", item1, item2, item3, item4, item5, item6, champId)
    redirect("champions/#{champId}")
end

get('/champions/:id') do
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    id = params[:id].to_i
    @result = db.execute("SELECT * FROM champions WHERE Cahmpion_Id=?", id).first
    @items = {}
    if @result['Item1'] != nil
        @items['Item1'] = db.execute("SELECT Name FROM items WHERE Item_Id = #{@result['Item1']}").first['Name']
    else
        @items['Item1'] = "no item yet"
    end

    if @result['Item2'] != nil
        @items['Item2'] = db.execute("SELECT Name FROM items WHERE Item_Id = #{@result['Item2']}").first['Name']
    else
        @items['Item2'] = "no item yet"
    end

    if @result['Item3'] != nil
        @items['Item3'] = db.execute("SELECT Name FROM items WHERE Item_Id = #{@result['Item3']}").first['Name']
    else
        @items['Item3'] = "no item yet"
    end

    if @result['Item4'] != nil
        @items['Item4'] = db.execute("SELECT Name FROM items WHERE Item_Id = #{@result['Item4']}").first['Name']
    else
        @items['Item4'] = "no item yet"
    end

    if @result['Item5'] != nil
        @items['Item5'] = db.execute("SELECT Name FROM items WHERE Item_Id = #{@result['Item5']}").first['Name']
    else
        @items['Item5'] = "no item yet"
    end

    if @result['Item6'] != nil
        @items['Item6'] = db.execute("SELECT Name FROM items WHERE Item_Id = #{@result['Item6']}").first['Name']
    else
        @items['Item6'] = "no item yet"
    end
    p @result
    slim(:"/show")
end

get('/register') do
    slim(:"/register")
end

post('/active_register') do
    username = params[:username]
    password = params[:password]
    confirm_password = params[:confirm_password]

    if (password == confirm_password)
        password_digest = BCrypt::Password.create(password)
        db = SQLite3::Database.new("db/db.db")
        db.results_as_hash = true
        db.execute('INSERT INTO "users" (username,pwdigest,permissions) VALUES (?,?,?)',username,password_digest,1)
        redirect('/login')
    else
        flash[:notice] = "passwords did not match"
        redirect('/register')
    end
    
end

get('/login') do
    slim(:"/login")
end

post('/active_login') do
    username=params[:username]
    password=params[:password]
    db = SQLite3::Database.new("db/db.db")
    db.results_as_hash = true
    result = db.execute("SELECT * From users WHERE username = ?",username).first
    if result == nil
        flash[:notice] = "No such username exists"
        redirect('/login')
    else
    pwdigest = result["pwdigest"]
    id = result["id"]
    currentuser = result["username"]
    permissions = result["permissions"]
        if BCrypt::Password.new(pwdigest) == password
          session[:id] = id
          session[:currentuser] = currentuser
          session[:permissions] = permissions
          p session[:id], session[:currentuser], session[:permissions]
          redirect('/')
        else
          flash[:notice] = "Wrong password"
          redirect('/login')
        end
    end
end 

get('/logout') do 
    session.clear
    redirect('/')
end
