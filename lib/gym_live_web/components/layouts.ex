defmodule GymLiveWeb.Layouts do
  use GymLiveWeb, :html

  embed_templates "layouts/*"

  def navigation_bar(assigns) do
    ~H"""
    <div class="fixed inset-x-0 bottom-0 z-50 bg-gray-900 border-t border-gray-800">
      <nav class="flex justify-around">
        <.link patch={~p"/edit_workout"} class="w-full">
          <.nav_icon name="hero-pencil-square" highlighted={@active_tab == :edit_workout} label="Add" />
        </.link>
        <.link patch={~p"/workouts"} class="w-full">
          <.nav_icon
            name="hero-document-chart-bar"
            highlighted={@active_tab == :view_workouts}
            label="History"
          />
        </.link>
        <.link patch={~p"/charts"} class="w-full">
          <.nav_icon name="hero-chart-bar" highlighted={@active_tab == :view_charts} label="Charts" />
        </.link>
        <.link patch={~p"/users/settings"} class="w-full">
          <.nav_icon name="hero-user" highlighted={@active_tab == :settings} label="Profile" />
        </.link>
      </nav>
    </div>
    """
  end

  attr :name, :string, required: true
  attr :highlighted, :boolean, default: false
  attr :label, :string, required: true

  def nav_icon(assigns) do
    ~H"""
    <div class={[
      "flex flex-col items-center py-4 transition duration-100 ease-in-out",
      if(@highlighted, do: "text-blue-500", else: "text-gray-400 hover:text-gray-200")
    ]}>
      <.icon name={@name} class="h-6 w-6 mb-1" />
      <span class="text-xs font-medium"><%= @label %></span>
    </div>
    """
  end
end
