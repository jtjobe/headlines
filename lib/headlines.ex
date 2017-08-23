defmodule Headlines do
  alias Headlines, as: H
  use GenServer


  def nyt do
    response = HTTPoison.get! "https://www.nytimes.com"
    links = get_links(response.body)
    total_link_count = Enum.count(links)
    indexed_links = Enum.with_index(links)

    Enum.each(indexed_links, fn(link) ->
      {link_data, link_index} = link
      all_to_list(link_data, link_index)
    end)
  end

  # def cnn do
  #   response = HTTPoison.get! "http://www.cnn.com"
  #   get_links(response.body)
  #   |> write_to_csv(&1, "cnn")
  # end

  def get_links(html) do
    Floki.find(html, "a")
  end

  # def extract_from_links(links) do
  #   Enum.map(links, fn(link) ->
  #     title = List.first(elem(link, 2))
  #     url   = elem(List.first(elem(link, 1)), 1)
  #     [title, url]
  #   end)
  # end

  def write_to_csv(links, network) do
    write_file = network_write_file(network)
    # IO.puts write_file

    File.open(write_file, [:write, :utf8], fn(file) ->
      Enum.map(links, fn(link) ->
        # if Enum.count(link) == 1 do

          IO.write(file, CSVLixir.write_row(link))
        # end
      end)
    end)
  end

  def all_to_list(data, index) do
    IO.puts "CALLED"

    if is_list(data) do
      flattened = List.flatten(data)

      if Enum.count(flattened) > 1 do
        Enum.each(flattened, fn(x) ->
          all_to_list(x, index)
        end)
      else
        IO.puts "SHIT WAS HIT!!!!"
        # is this ever hit? maybe not..
        #add_to_collector(flattened)
      end

    end

    if is_tuple(data) do
      new_data = List.flatten(Tuple.to_list(data))
      all_to_list(new_data, index)
    end

    if is_binary(data) do
      collection_name = collection_name(index)
      add_to_collector(data, collection_name)
    end

  end

  def collection_name(index) do
    "index_#{index}_collection"
  end

  def start_link(index) do
    name = collection_name(index)
    GenServer.start_link(__MODULE__, [], name: name)
  end

  def init(state) do
    {:ok, state}
  end

  def add_to_collector(item, collection_name) do
    GenServer.cast(collection_name, {:add_to_collector, item})
  end

  def handle_cast({:add_to_collector, item}, state) do
    new_state = [item | state]
    IO.inspect ["NEW_STATE", new_state]
    {:noreply, new_state}
  end

  def get_collection(collection_name) do
    GenServer.call(collection_name, :get_collection)
  end

  def handle_call(:get_collection, _from, state) do
    {:reply, state, state}
  end

  defp network_write_file(network) do
    "tmp/#{network}.csv"
  end

end
