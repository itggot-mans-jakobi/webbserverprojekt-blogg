require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"

enable :sessions    

get("/") do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    
    result = db.execute("SELECT PostId, PostText FROM posts")

    slim(:index, locals:{
        post: result})
end

post("/user_login") do
    username = params["username"]
    password = params["password"]
    hashat_password = BCrypt::Password.create(password)

    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true

   
    if params["submit_button"] == "Login"
        result_password = db.execute("SELECT Password FROM users where Username = 'username'")
        if hashat_password == result_password[0][0]
            session[:logged_in] = true
        end
    end

    if params["submit_button"] == "Create user"
        db.execute("INSERT INTO users (Username, Password) VALUES (?,?)", username, hashat_password)
    end

    redirect("/")
end