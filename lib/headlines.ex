defmodule Headlines do

  def nyt do
    response = HTTPoison.get! "https://www.nytimes.com"
    get_links(response.body)
  end

  def cnn do 
   response = HTTPoison.get! "http://www.cnn.com"
   get_links(response.body)
  end

  def link_titles(links) do 
    Enum.map(links, fn(link) ->
      headline = elem(link, 2)
      IO.inspect headline
    end)
  end

  defp get_links(html) do
    Floki.find(html, "a")
  end

end
