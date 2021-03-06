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
  # erb :'Webpages/pad', :layout => false
end

get '/invalid_project' do
  "Project not found"
end

get '/no_access' do
  "You do not have access to this project"
end

get '/pad/:num' do
  no_user_redirect
  proj = Project.find_by(id: params[:num])
  redirect '/invalid_project' if (!proj)
  redirect "/no_access" if !proj.users.include?(curr_user)
  session[:pad] = params[:num]
  if @env['REMOTE_ADDR'] == "127.0.0.1"
    @host = "ws://localhost:3001".to_json
  else
    @host = "ws://172.46.0.218:3001".to_json
  end  
  erb :'Webpages/pad', :layout => false
end

get '/list_projects' do
  user = curr_user
  if (!user)
    [].to_json
  else
    user.projects.map {|x| x.name}.to_json
  end
end

get '/list_users' do
  user = curr_user
  if (!user)
    [].to_json
  else
    case params[:filter]
    when "all"
      Users.all.map {|x| x.name}.to_json
    when "by_project"
      proj = Project.find_by(id: params[:project_id].to_i)
      user = User.find_by(id: params[:user_name].to_i)
      user.projects << proj

      # binding.pry
      response = user.username.to_json
      response
      # if (!proj)
      #   [].to_json
      # else
      #   proj.users.map {|x| x.name}.to_json
      # end
    when "by_name"
      User.all.where('lower(username) LIKE ?', "#{params[:name]}%".downcase).map {|x| {name:x.username, id: x.id}}.to_json
    end
  end
end

get '/Webpages/page' do
  no_user_redirect
  @user = curr_user
  
  @user_projects = []
  @user.projects.each do |x|
    @user_projects << x 
  end
  
  erb :'Webpages/page', layout: false
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

get '/my_ip' do
  @env['REMOTE_ADDR']
end

get '/newproj' do
  project_creator = User.find(params[:user].to_i)
  if (!project_creator || project_creator != curr_user)
    {status: false, name: params[:name], error: ["User not found"]}.to_json
  else
    proj = Project.new(name: params[:name], description: params[:description])
    if (!proj.save)
      {status: false, name: params[:name], error: proj.errors.full_messages}.to_json
      
    else
      proj.add(project_creator)
      proj.set_admin(project_creator)
      {status: true, name: params[:name], error: ["None"]}.to_json
    end
  end
end


helpers do
  def curr_user
    session[:user_id] == nil ? nil : User.find_by(id: session[:user_id])
  end

  def no_user_redirect
    redirect '/Webpages/Signin' if !curr_user
  end
end