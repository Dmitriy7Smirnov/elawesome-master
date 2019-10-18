defmodule Parser do


  def get_content do
    {:ok, {{_version, 200, _reasonPhrase}, _headers, body}} = :httpc.request(:get, {'https://raw.githubusercontent.com/h4cc/awesome-elixir/master/README.md', []}, [], [])
    #{:ok, mp} = :re.compile("basic")
    #{_body, answer} = :re.inspect(mp, :erlang.list_to_binary(body))
    #nswer
    answer = String.split(:erlang.list_to_binary(body), "\n")
    #for item <- answer, ref_string?(item),  do: item
    #IO.inspect IEx.Info.info(body)
    #for item <- answer, do: IO.inspect "#{item} \n"
    parse(answer, nil, [])
  end

  def get_stars do
    url = 'https://github.com/rozap/exquery'
    {:ok, {{_version, 200, _reasonPhrase}, _headers, body}} = :httpc.request(:get, {url, []}, [], [])
    #str = "aria-label=\"31 users starred this repository\">"
    starsStr = case Regex.run(~r/(".* users starred this repository">)/, :erlang.list_to_binary(body)) do
      [ _, starsStr] -> starsStr
      _ -> false
    end
    stars = case Regex.run(~r/(\d+)/, starsStr) do
      [ _, stars] -> stars
      _ -> false
    end
    stars
  end

  def gsf do
    url = 'https://github.com/rozap/exquery'
    {:ok, {{_version, 200, _reasonPhrase}, _headers, body}} = :httpc.request(:get, {url, []}, [], [{:body_format, :binary}])
    numAsText = Floki.find(body, "a.social-count.js-social-count") |> Floki.text
    get_number_from_text(numAsText)
  end

  defp get_number_from_text(text) do
    stars = case Regex.run(~r/(\d+)/, text) do
              [ _, stars] -> stars
              _ -> false
            end
    stars
  end

  def get_time do
    url = 'https://github.com/rozap/exquery'
    {:ok, {{_version, 200, _reasonPhrase}, _headers, body}} = :httpc.request(:get, {url, []}, [], [])
    #str = "aria-label=\"31 users starred this repository\">"
    dates = Regex.scan(~r/(><time-ago datetime="\d{4}-\d{2}-\d{2}T)/, :erlang.list_to_binary(body))
    dates1 = for [el1, _el2] <- dates do
      [e1, _] = Regex.run(~r/(\d{4}-\d{2}-\d{2})/, el1)
      e1
    end
    Enum.max(dates1)
  end

  def parse([head | tail], topic, resultList) do
      case topic_string?(head) do
        true -> parse(tail, get_topic(head), resultList)
        false -> case ref_string?(head) do
                     true -> case get_params(topic, head) do
                          false -> parse(tail, topic, resultList)
                              _ -> parse(tail, topic, [get_params(topic, head) | resultList])
                             end
                     false -> parse(tail, topic, resultList)
                 end
      end
  end

  def parse([], _topic, resultList) do
    Enum.reverse(resultList)
  end

  def topic_string?(str) do
    regexp = "^(##)"
    case :re.run(str, regexp) do
      :nomatch -> false
      {:match, _} -> true
    end
  end

  def ref_string?(str) do
    result = case Regex.run(~r/\((.*github\.com.*)\)/, str) do
      [ _, _href] -> true
      _ -> false
    end
    result
  end

  def get_topic(str) do
    #str = "## Cloud Infrastructure and Management"
    topic = case String.split(str, "## ") do
      [_, topic] -> topic
      _ -> false
    end
    topic
  end

  def get_params(topic, str) do
    #str = "* [Awesome Erlang](https://gitafhub.com/drobakowski/awesome-erlang) - A curated list of awesome Erlang libraries, resources and shiny things."
    name = case Regex.run(~r/\[(.*)\]/, str) do
      [ _, name] -> name
      _ -> false
    end
    href = case Regex.run(~r/\((.*github\.com.*)\)/, str) do
      [ _, href] -> href
      _ -> false
    end
    description = case Regex.run(~r/( - .*$)/, str) do
      [ _, description] -> description
      _ -> false
    end
    if topic && name && href && description do
      {topic, name, href, description}
    else
      false
    end
  end

end
