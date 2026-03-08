defmodule PomodoRobWeb.PageController do
  use PomodoRobWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
