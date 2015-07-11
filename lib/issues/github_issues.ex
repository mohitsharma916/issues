defmodule Issues.GithubIssues do
  @moduledoc """
  Core Github module to fetch the issues for a specified project of
  a specified user.
  """

  use Timex

  @user_agent [{"User-agent","Mohit Sharma mohit.sharma@housing.com"}]
  @required_keys ["created_at","state","title","user"]
  @github_url Application.get_env(:issues,:github_url)

  def fetch(user,project) do
    issue_url(user,project)
    |> HTTPoison.get(@user_agent)
    |> parse_http_response
    |> handle_http_response
    |> sort_by_created_at
  end

  def issue_url(user,project) do
    "#{@github_url}/repos/#{user}/#{project}/issues"
  end

  def parse_http_response(url_response) do 
    case url_response do
      {:ok,%HTTPoison.Response{status_code: 200, body: body}} -> {:ok,:jsx.decode(body)}
      {:ok,%HTTPoison.Response{status_code: _,body: body}} -> {:error,:jsx.decode(body)}
      {:error,%HTTPoison.Error{id: _,reason: reason}} -> {:error,:jsx.decode(reason)}
    end
  end

  def handle_http_response({:ok,body}) do
    body
    |> Enum.map(fn issue -> 
                    issue
                    |> Dict.take(@required_keys) 
                    |> Dict.update!("user",fn user -> user["login"] end)
      end)
  end

  def handle_http_response({:error,body}) do
    IO.puts """
      There was an error handling the request.
      Message: #{body["message"]}
    """
    System.halt(1)
  end

  def sort_by_created_at(issue_list) do
    issue_list
    |> Enum.sort(fn %{"created_at" => created_at1},%{"created_at" => created_at2} -> 
                  time1 = (created_at1 |> DateFormat.parse("{ISOz}"))
                  time2 = (created_at2 |> DateFormat.parse("{ISOz}"))
                  cond do
                    time1 < time2 -> false
                    true -> true
                  end
    end)
  end

end
