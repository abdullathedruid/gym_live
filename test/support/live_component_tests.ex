defmodule LiveComponentTests do
  # https://gist.github.com/mcrumm/8e6b0a98196dd74a841d850c70805f50

  defmodule Driver do
    use Phoenix.LiveView

    def render(assigns) do
      ~H"""
      <.live_component :if={@lc_module} module={@lc_module} {@lc_attrs} />
      """
    end

    def handle_call({:run, func}, _, socket) when is_function(func, 1) do
      func.(socket)
    end

    def mount(_, _, socket) do
      {:ok, assign(socket, lc_module: nil, lc_attrs: %{})}
    end

    ## Test Helpers
    def run(lv, func) do
      GenServer.call(lv.pid, {:run, func})
    end
  end

  require Phoenix.LiveViewTest

  defmacro live_component_isolated(conn, module, attrs \\ []) do
    quote bind_quoted: binding() do
      {:ok, lv, _html} = Phoenix.LiveViewTest.live_isolated(conn, Driver)

      attrs = attrs |> Map.new() |> Map.put_new(:id, module)

      Driver.run(lv, fn socket ->
        {:reply, :ok, Phoenix.Component.assign(socket, lc_module: module, lc_attrs: attrs)}
      end)

      {:ok, lv, Phoenix.LiveViewTest.render(lv)}
    end
  end

  def live_component_intercept(lv, func) when is_function(func) do
    Driver.run(lv, fn socket ->
      name = :"lcd_intercept_#{System.unique_integer([:positive, :monotonic])}"
      ref = {:intercept, lv, name, :handle_info}
      {:reply, ref, Phoenix.LiveView.attach_hook(socket, name, :handle_info, func)}
    end)
  end

  def live_component_remove_intercept({:intercept, lv, name, stage}) do
    Driver.run(lv, fn socket ->
      {:reply, :ok, Phoenix.LiveView.detach_hook(socket, name, stage)}
    end)
  end
end
