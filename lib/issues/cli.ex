defmodule Issues.CLI do

  @default_count 4
  @help_string """
  Please run in the following format
  issue <user> <name> [issue_count | #{@default_count}]
  """
  @moduledoc """
  Handles the command line parsing
  and dispatch the commands to various 
  modules.
  """

  @doc """
  The main function used by escript to make this project executable.
  """
  def main(argv) do
    argv
    |> parse_args
  end

  @doc """
  Using OptionParser to parse the command line arguments.
  If --help or -h is provided, atom :help is returned.
  Otherwise, the setup variables for the project are returned
  in the format [github_user,project_name,optional_count].
  In case of invalid command line arguments, :error will be returned.
  """
  def parse_args(argv) do
    argv
    |> OptionParser.parse(strict: [help: :boolean],aliases: [h: :help])
    |> return_args
    |> process
    |> beautify
  end

  @doc """
  Helper function to parse the command line arguments.
  """
  def return_args(params) do
    case params do
      {[help: true],_,_} ->
        :help
      {_,[user,project,count],_} ->
        [user,project,String.to_integer(count)]
      {_,[user,project],_} ->
        [user,project,@default_count]
    end
  end

  def process(:help) do
    IO.puts @help_string
    System.halt(0)
  end

  def process([user,project,issue_count]) do
    Issues.GithubIssues.fetch(user,project)
    |> get_first_n(issue_count)
  end

  def get_first_n(issue_list,issue_count) do
    issue_list
    |> Enum.take(issue_count)
  end

  def beautify(issue_list) do
    issue_list
    |> Enum.each(fn issue -> issue |> print_issue end)
  end

  def print_issue(%{"title" => title,"user" => user,"state" => state}) do
    IO.puts "ISSUE: #{title}, RAISED BY: #{user}, STATUS: #{state}"
  end

end
