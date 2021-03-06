#
# tk/scale.rb : treat scale widget
#
require 'tk'

class TkScale<TkWindow
  TkCommandNames = ['scale'.freeze].freeze
  WidgetClassName = 'Scale'.freeze
  WidgetClassNames[WidgetClassName] = self

  def create_self(keys)
    if keys and keys != None
      if keys.key?('command') && ! keys['command'].kind_of?(String)
        cmd = keys.delete('command')
        keys['command'] = proc{|val| cmd.call(val.to_f)}
      end
      #tk_call_without_enc('scale', @path, *hash_kv(keys, true))
      tk_call_without_enc(self.class::TkCommandNames[0], @path, 
                          *hash_kv(keys, true))
    else
      #tk_call_without_enc('scale', @path)
      tk_call_without_enc(self.class::TkCommandNames[0], @path)
    end
  end
  private :create_self

  def _wrap_command_arg(cmd)
    proc{|val|
      if val.kind_of?(String)
        cmd.call(number(val))
      else
        cmd.call(val)
      end
    }
  end
  private :_wrap_command_arg

  def configure_cmd(slot, value)
    configure(slot=>value)
  end

  def configure(slot, value=None)
    if (slot == 'command' || slot == :command)
      configure('command'=>value)
    elsif slot.kind_of?(Hash) && 
        (slot.key?('command') || slot.key?(:command))
      slot = _symbolkey2str(slot)
      slot['command'] = _wrap_command_arg(slot.delete('command'))
    end
    super(slot, value)
  end

  def command(cmd=Proc.new)
    configure('command'=>cmd)
  end

  def get(x=None, y=None)
    number(tk_send_without_enc('get', x, y))
  end

  def coords(val=None)
    tk_split_list(tk_send_without_enc('coords', val))
  end

  def identify(x, y)
    tk_send_without_enc('identify', x, y)
  end

  def set(val)
    tk_send_without_enc('set', val)
  end

  def value
    get
  end

  def value= (val)
    set(val)
    val
  end
end
