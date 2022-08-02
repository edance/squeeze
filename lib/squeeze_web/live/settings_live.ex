defmodule SqueezeWeb.SettingsLive do
  use SqueezeWeb, :live_view

  alias Phoenix.LiveView.Helpers
  alias Squeeze.Accounts

  @moduledoc """
  This is the module for the settings live view
  """

  @impl true
  def mount(_params, session, socket) do
    user = socket.assigns[:current_user] || get_current_user(session)

    socket = assign(socket,
      page_title: "Settings",
      current_user: user,
      changeset: Accounts.change_user(user)
    )

    {:ok, socket}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    user = socket.assigns.current_user

    case Accounts.update_user(user, user_params) do
      {:ok, _} ->
        socket = socket
        |> put_flash(:info, gettext("Your preferences have been updated"))
        |> redirect(to: Routes.dashboard_path(socket, :index))
        {:noreply, socket}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def link_item(socket, current_action, text, route_action) do
    class_list = "nav-link#{if current_action == route_action, do: " active"}"
    Helpers.live_redirect(text, class: class_list, to: Routes.settings_path(socket, route_action))
  end

  def membership_status(%{current_user: user}) do
    case user.subscription_status do
      :free -> "Free Account"
      _status -> "Premium Account"
    end
  end
end
