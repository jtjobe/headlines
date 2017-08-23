defmodule Headlines do
  alias Headlines, as: H
  use GenServer


  def nyt do
    response = HTTPoison.get! "https://www.nytimes.com"
    get_links(response.body)
    #|> write_to_csv("nyt")
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

  def all_to_list(data) do
    IO.puts ""
    IO.puts ""
    type = Util.typeof(data)
    IO.puts "START TYPE = #{type}"
    IO.inspect data


    if is_list(data) do
      IO.puts "LIST"
      flattened = List.flatten(data)

      if Enum.count(flattened) > 1 do
        IO.puts "LIST.count > 1"
        IO.inspect flattened

        Enum.each(flattened, fn(x) ->
          all_to_list(x)
        end)
      else
        IO.puts "ADD"
        add_to_collector(flattened)
      end

    end

    if is_tuple(data) do
      IO.puts "TUPLE"
      new_data = List.flatten(Tuple.to_list(data))

      all_to_list(new_data)
    end

    if is_binary(data) do
      add_to_collector(data)
    end

    end_type = Util.typeof(data)
    IO.puts "END TYPE = #{end_type}"


    #IO.inspect ["END", data]
  end

  def start_link do
    GenServer.start_link(__MODULE__, [], name: ListCollector)
  end

  def init(state) do
    {:ok, state}
  end

  def add_to_collector(item) do
    GenServer.cast(ListCollector, {:add_to_collector, item})
  end

  def handle_cast({:add_to_collector, item}, state) do
    new_state = [item | state]
    IO.inspect ["NEW_STATE", new_state]
    {:noreply, new_state}
  end

  def get_collection do
    GenServer.call(ListCollector, :get_collection)
  end

  def handle_call(:get_collection, _from, state) do
    {:reply, state, state}
  end

  defp network_write_file(network) do
    "tmp/#{network}.csv"
  end

end
