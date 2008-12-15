task :ls, :roles => :application do
  run "cd /; ls"
end