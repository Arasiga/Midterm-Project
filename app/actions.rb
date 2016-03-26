# Homepage (Root path)
get '/' do
  session[:user_id] = nil
  erb :'Webpages/home', layout: false
end

post '/Webpages/Signin' do 

  @username = params[:username]
  @password = params[:password]

  @user = User.find_by(username: @username)
  
  if @user && @password == @user.password
    session[:user_id] = @user.id
    redirect '/Webpages/page'
  else 
    @login_failed = true
    erb :'Webpages/Signin'
  end
end

get '/Webpages/Signin' do
  session[:user_id] = nil
  erb :'Webpages/Signin'
end

get '/pad' do
  "Go away"
  erb :'Webpages/pad', :layout => false
end

get '/pad/:num' do
  erb :'Webpages/pad', :layout => false
end

get '/Webpages/page' do
  if (!session[:user_id])
    @login_failed = true
    erb :'Webpages/Signin'
  else
    @user = User.find(session[:user_id])
    if (!@user)
      @login_failed = true
      erb :'Webpages/Signin'
    else
      erb :'Webpages/page', layout: false
    end
  end  
end

get '/Webpages/Signup' do
  erb :'Webpages/Signup'
end

get '/Webpages/about' do
  erb :'Webpages/about'
end

get '/test' do
  erb :'/Webpages/test'
end

post '/Webpages/Signup' do
  @user = User.new(
    first_name: params[:first_name],
    last_name: params[:last_name],
    country: params[:country],
    email: params[:email],
    username: params[:username],
    password: params[:password],
    repeat_password: params[:repeat_password]
  )
  if @user.save
    redirect '/'
  else
    erb :'Webpages/Signup'
  end
end

get '/Webpages/database' do
  @users = User.all
  erb :'Webpages/database'
end

get '/newproj' do
  project_creator = User.find(params[:user].to_i)
  if (!project_creator)
    {status: false, error: ["User not found"]}.to_json
  else
    proj = Project.new(name: params[:name], description: params[:description])
    if (!proj.save)
      {status: false, error: proj.errors.full_messages}.to_json
      
    else
      proj.add(project_creator)
      proj.set_admin(project_creator)
      {status: true, error: ["None"]}.to_json
    end
  end
end


