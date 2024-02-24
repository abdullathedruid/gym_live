defmodule GymLiveWeb.Layouts do
  use GymLiveWeb, :html

  embed_templates "layouts/*"

  def navigation_bar(assigns) do
    ~H"""
    <div class="fixed left-2 bottom-2 right-2 p-5 px-6 m-2 flex items-center justify-around bg-gray-800 shadow-3xl text-gray-400 rounded-2xl">
      <.link patch={~p"/edit_workout"}>
        <.nav_icon name="hero-pencil-square" highlighted={@active_tab == :edit_workout} />
      </.link>
      <.nav_icon name="hero-document-chart-bar" />
      <.nav_icon name="hero-chart-bar" />
      <.nav_icon name="hero-user" />
    </div>
    """
  end

  attr :name, :string, required: true
  attr :highlighted, :boolean, default: false

  def nav_icon(assigns) do
    ~H"""
    <div class={[
      "flex flex-col items-center transition ease-in duration-200 cursor-pointer",
      if(@highlighted, do: "text-blue-400", else: "hover:text-blue-200")
    ]}>
      <.icon name={@name} class="h-8 w-8" />
    </div>
    """
  end
end
