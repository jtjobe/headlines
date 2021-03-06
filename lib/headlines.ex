defmodule Headlines do
  alias Headlines, as: H
  use GenServer

  defp network_write_file(network) do
    "tmp/#{Atom.to_string(network)}.csv"
  end

  def nyt do
    response = HTTPoison.get! "https://www.nytimes.com"
    links = get_links(response.body)

    normalized_links =
      Enum.map(links, fn(link) ->
        normalize_to_list(link)
      end)

    write_file = network_write_file(:new_york_times)

    File.open(write_file, [:write, :utf8], fn(file) ->

      Enum.map(normalized_links, fn(link) ->
        IO.write(file, CSVLixir.write_row(link))
      end)
    end)

    # start_link(:new_york_times)

    # Enum.each(indexed_links, fn(link) ->
    #   {link_data, link_index} = link
    #   collection_name = collection_name(link_index)
    #   start_link(collection_name)

    #   all_to_list(link_data, link_index)
    # end)

    # Enum.each(indexed_links, fn(link) ->
    #   {link_data, link_index} = link
    #   collection_name = collection_name(link_index)
    #   compile_collection(collection_name, :new_york_times)
    # end)

    # write_to_csv(:new_york_times)
  end


  def get_links(html) do
    Floki.find(html, "a")
  end

  def normalize_to_list(link) do

    data = if is_tuple(link), do: Tuple.to_list(link), else: link

    Enum.reduce(data, [], fn(x, acc) ->

      if is_binary(x) do
        [x | acc]
      else
        t = Enum.reduce(x, [], fn(y, acc) ->
          if is_tuple(y), do: [ Tuple.to_list(y) | acc], else: [ y | acc ]
        end)

        [t | acc]
      end
    end) |> List.flatten
    |> Enum.map(fn(x) ->
      unless is_binary(x) do
        IO.inspect x
      end
      # String.strip(x)
    end)
  end

  # def write_to_csv(network_atom) do
  #   write_file = network_write_file(network_atom)

  #   File.rm(write_file)

  #   File.open(write_file, [:write, :utf8], fn(file) ->

  #     # links = get_network_collection(network_atom)

  #     Enum.map(links, fn(link) ->
  #       IO.write(file, CSVLixir.write_row(link))
  #     end)
  #   end)
  # end


  # GenServer functions

  # def start_link(name) do
  #   GenServer.start_link(__MODULE__, [], name: name)
  # end

  # def init(state) do
  #   {:ok, state}
  # end

  # def add_to_collector(item, collection_name) do
  #   GenServer.cast(collection_name, {:add_to_collector, item})
  # end

  # def handle_cast({:add_to_collector, item}, state) do
  #   new_state = [item | state]
  #   {:noreply, new_state}
  # end

  # def compile_collection(collection_name, network_name) do
  #   GenServer.cast(collection_name, {:compile_collection, network_name})
  # end

  # def handle_cast({:compile_collection, network_name}, state) do
  #   add_to_collector(state, network_name)
  #   {:noreply, state}
  # end

  # def get_network_collection(network_name) do
  #   GenServer.call(network_name, :get_network_collection)
  # end

  # def handle_call(:get_network_collection, _from, state) do
  #   {:reply, state, state}
  # end
end
