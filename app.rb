require "sinatra"
require "slim"
require "sqlite3"
require "bcrypt"

enable :sessions    

get("/") do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    
    result = db.execute("SELECT PostId, PostText, Username FROM posts")

    slim(:index, locals:{
        post: result})
end

get("/:user") do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    # params["user"]

    result = db.execute("SELECT PostId, PostText, Username FROM posts")

    slim(:userpage, locals:{
        post: result,
        username_viev: params["user"]
    })
end

get("/:user/edit") do
    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true

    result = db.execute("SELECT PostId, PostText, Username FROM posts")

    slim(:userpage, locals:{
        post: result
    })
end

post("/user_login") do
    username = params["username"]
    password = params["password"]
    

    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true
    if password == ""
        redirect("/")
    end
   
    if params["submit_button"] == "Login"
        result_password = db.execute("SELECT Password FROM users WHERE Username=?", username)
        if BCrypt::Password.new(result_password[0]["Password"]) == password
            session[:logged_in] = true
            session[:user] = username
            
            redirect("/")
        # else
        #     redirect("/")
        end
    end
    if params["submit_button"] == "Create user"
        db.execute("INSERT INTO users (Username, Password) VALUES (?,?)", username, BCrypt::Password.create(password))
        session[:logged_in] = true
        session[:user] = username
    end

    redirect("/")
end


post("/user_logout") do
    session[:logged_in] = false
    session[:user] = ""
    redirect("/")
end

post("/post_new") do
    post_text = params["post_text"]
    username_post = session[:user]
    if post_text == ""
        redirect("/user")
    end

    db = SQLite3::Database.new("db/database.db")
    db.results_as_hash = true    

    post_text = params["post_text"]
    db.execute("INSERT INTO posts (Username, PostText) VALUES (?,?)", username_post, post_text)

    redirect("/")
end
