defmodule OrganizerTest do
  use ExUnit.Case
  # doctest Organizer

  defmodule SimpleExample do
    use Interactor
    def handle_call(%{foo: :bar}), do: {:ok, %{bar: :foo}}
    def cleanup(%{bar: :foo}), do: {:ok, %{foo: :bar}}
  end

  defmodule SuccessExample do
    use Interactor
    def handle_call(%{bar: :foo}), do: {:ok, true}
  end

  defmodule FailureExample do
    use Interactor
    def handle_call(%{bar: :foo}) do
      {:error, "oh no"}
    end
  end

  defmodule SimpleExample2 do
    use Interactor
    def handle_call(_args), do: {:ok, %{bar: :foo, baz: :quux}}
    def cleanup(%{bar: :foo, baz: :quux}), do: {:ok, %{bar: :foo}}
  end

  defmodule ExceptionExample do
    use Interactor
    def handle_call(%{bar: :foo}) do
      raise "A HUGE EXCEPTION"
    end
  end

  defmodule MyOrganizer do
    use Interactor.Organizer

    organize [SimpleExample, SuccessExample]
  end

  defmodule CleanupOrganizer do
    use Interactor.Organizer

    organize [SimpleExample, FailureExample]
  end

  defmodule ExceptionOrganizer do
    use Interactor.Organizer

    organize [SimpleExample, SimpleExample2, ExceptionExample]
  end

  test "it works just fine" do
    assert {:ok, true} == Interactor.call(MyOrganizer, %{foo: :bar})
  end

  test "clean up after" do
    assert {:error, "oh no", %{foo: :bar}} == Interactor.call(CleanupOrganizer, %{foo: :bar})
  end

  test "it cleans up even if it catches an exception" do
    assert {:error, %RuntimeError{message: "A HUGE EXCEPTION"}, %{foo: :bar}} == Interactor.call(ExceptionOrganizer, %{foo: :bar})
  end
end
