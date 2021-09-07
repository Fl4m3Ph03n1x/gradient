defmodule TypedGenServer.MultiServer do
  use GenServer
  use GradualizerEx.TypeAnnotation

  ## recompile(); GradualizerEx.type_check_file(:code.which(TypedGenServer.MultiServer), [:infer])

  ## Try switching between the definitions and see what happens
  @type message :: Proto.Echo.req() | Proto.Hello.req()
  #@type message :: Proto.Echo.req()
  #@type message :: {:echo_req, String.t()} | {:hello, String.t()}

  @type state :: map()

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{})
  end

  @spec echo(pid(), String.t()) :: String.t()
  #@spec echo(pid(), String.t()) :: {:echo_req, String.t()}
  def echo(pid, message) do
    case annotate_type( GenServer.call(pid, {:echo_req, message}), Proto.Echo.res() ) do
      ## Try changing the pattern
      {:echo_res, response} -> response
    end
  end

  @spec hello(pid, String.t()) :: :ok
  def hello(pid, name) do
    case annotate_type( GenServer.call(pid, {:hello, name}), Proto.Hello.res() ) do
      :ok -> :ok
    end
  end

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call(m, from, state) do
    {:noreply, handle(m, from, state)}
  end

  @spec handle(message(), any, any) :: state()
  ## Try breaking the pattern match, e.g. by changing 'echo_req'
  def handle({:echo_req, payload}, from, state) do
    GenServer.reply(from, {:echo_res, payload})
    state
  end

  ## Try commenting out the following clause
  def handle({:hello, name}, from, state) do
    IO.puts("Hello, #{name}!")
    GenServer.reply(from, :ok)
    state
  end
end
