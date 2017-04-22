::ActionView::TemplateRenderer.class_eval do
  alias_method :render_with_layout_without_tracebin, :render_with_layout

  def render_with_layout(path, locals, *args, &block)
    layout = nil

    if path
      if method(:find_layout).arity == 3
        layout = find_layout(path, locals.keys, [formats.first])
      else
        layout = find_layout(path, locals.keys)
      end
    end

    if layout
      start_time = Time.now
      render_with_layout_without_tracebin(path, locals, *args, &block)
      end_time = Time.new

      event_data = [
        'render_layout.action_view',
        start_time,
        end_time,
        {
          identifier: layout.identifier
        }
      ]

      ::Vizsla::Patches.handle_event :action_view_layout, event_data
    else
      render_with_layout_without_tracebin(path, locals, *args, &block)
    end
  end
end
