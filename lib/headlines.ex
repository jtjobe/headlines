defmodule Headlines do

  def nyt do
    response = HTTPoison.get! "https://www.nytimes.com"
    get_links(response.body)
    |> extract_from_links
    |> write_to_csv
  end

  def cnn do
    response = HTTPoison.get! "http://www.cnn.com"
    get_links(response.body)
    |> extract_from_links
    |> write_to_csv
  end

  def get_links(html) do
    Floki.find(html, "a")
  end

  def extract_from_links(links) do
    Enum.map(links, fn(link) ->
      title = List.first(elem(link, 2))
      url   = elem(List.first(elem(link, 1)), 1)
      [title, url]
    end)
  end

  def write_to_csv(links) do
    File.open("tmp/nyt.txt", [:write, :utf8], fn(file) ->
      Enum.map(links, fn(link) ->
        # if Enum.count(link) == 1 do
          IO.write(file, CSVLixir.write_row(link))
        # end
      end)
    end)
  end

end
