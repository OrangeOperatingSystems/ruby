#
# tk/menu.rb : treat menu and menubutton
#
require 'tk'
require 'tk/itemconfig'
require 'tk/menuspec'

module TkMenuEntryConfig
  include TkItemConfigMethod

  def __item_cget_cmd(id)
    [self.path, 'entrycget', id]
  end
  private :__item_cget_cmd

  def __item_config_cmd(id)
    [self.path, 'entryconfigure', id]
  end
  private :__item_config_cmd

  def __item_listval_optkeys(id)
    []
  end
  private :__item_listval_optkeys

  alias entrycget itemcget
  alias entryconfigure itemconfigure
  alias entryconfiginfo itemconfiginfo
  alias current_entryconfiginfo current_itemconfiginfo

  private :itemcget, :itemconfigure
  private :itemconfiginfo, :current_itemconfiginfo
end

class TkMenu<TkWindow
  include TkMenuEntryConfig
  extend TkMenuSpec

  TkCommandNames = ['menu'.freeze].freeze
  WidgetClassName = 'Menu'.freeze
  WidgetClassNames[WidgetClassName] = self

  #def create_self(keys)
  #  if keys and keys != None
  #    tk_call_without_enc('menu', @path, *hash_kv(keys, true))
  #  else
  #    tk_call_without_enc('menu', @path)
  #  end
  #end
  #private :create_self

  def self.new_menuspec(menu_spec, parent = nil, tearoff = false, keys = nil)
    if parent.kind_of?(Hash)
      keys = _symbolkey2str(parent)
      parent = keys.delete('parent')
      tearoff = keys.delete('tearoff')
    elsif tearoff.kind_of?(Hash)
      keys = _symbolkey2str(tearoff)
      tearoff = keys.delete('tearoff')
    elsif keys
      keys = _symbolkey2str(keys)
    else
      keys = {}
    end

    widgetname = keys.delete('widgetname')
    _create_menu(parent, menu_spec, widgetname, tearoff, keys)
  end

  def tagid(id)
    #id.to_s
    _get_eval_string(id)
  end

  def activate(index)
    tk_send_without_enc('activate', _get_eval_enc_str(index))
    self
  end
  def add(type, keys=nil)
    tk_send_without_enc('add', type, *hash_kv(keys, true))
    self
  end
  def add_cascade(keys=nil)
    add('cascade', keys)
  end
  def add_checkbutton(keys=nil)
    add('checkbutton', keys)
  end
  def add_command(keys=nil)
    add('command', keys)
  end
  def add_radiobutton(keys=nil)
    add('radiobutton', keys)
  end
  def add_separator(keys=nil)
    add('separator', keys)
  end
  def index(index)
    ret = tk_send_without_enc('index', _get_eval_enc_str(index))
    (ret == 'none')? nil: number(ret)
  end
  def invoke(index)
    _fromUTF8(tk_send_without_enc('invoke', _get_eval_enc_str(index)))
  end
  def insert(index, type, keys=nil)
    tk_send_without_enc('insert', _get_eval_enc_str(index), 
                        type, *hash_kv(keys, true))
    self
  end
  def delete(first, last=nil)
    if last
      tk_send_without_enc('delete', _get_eval_enc_str(first), 
                          _get_eval_enc_str(last))
    else
      tk_send_without_enc('delete', _get_eval_enc_str(first))
    end
    self
  end
  def popup(x, y, index=nil)
    if index
      tk_call_without_enc('tk_popup', path, x, y, 
                          _get_eval_enc_str(index))
    else
      tk_call_without_enc('tk_popup', path, x, y)
    end
    self
  end
  def post(x, y)
    _fromUTF8(tk_send_without_enc('post', x, y))
  end
  def postcascade(index)
    tk_send_without_enc('postcascade', _get_eval_enc_str(index))
    self
  end
  def postcommand(cmd=Proc.new)
    configure_cmd 'postcommand', cmd
    self
  end
  def set_focus
    tk_call_without_enc('tk_menuSetFocus', path)
    self
  end
  def tearoffcommand(cmd=Proc.new)
    configure_cmd 'tearoffcommand', cmd
    self
  end
  def menutype(index)
    tk_send_without_enc('type', _get_eval_enc_str(index))
  end
  def unpost
    tk_send_without_enc('unpost')
    self
  end
  def yposition(index)
    number(tk_send_without_enc('yposition', _get_eval_enc_str(index)))
  end

=begin
  def entrycget(index, key)
    case key.to_s
    when 'text', 'label', 'show'
      _fromUTF8(tk_send_without_enc('entrycget', 
                                    _get_eval_enc_str(index), "-#{key}"))
    when 'font', 'kanjifont'
      #fnt = tk_tcl2ruby(tk_send('entrycget', index, "-#{key}"))
      fnt = tk_tcl2ruby(_fromUTF8(tk_send_without_enc('entrycget', _get_eval_enc_str(index), '-font')))
      unless fnt.kind_of?(TkFont)
        fnt = tagfontobj(index, fnt)
      end
      if key.to_s == 'kanjifont' && JAPANIZED_TK && TK_VERSION =~ /^4\.*/
        # obsolete; just for compatibility
        fnt.kanji_font
      else
        fnt
      end
    else
      tk_tcl2ruby(_fromUTF8(tk_send_without_enc('entrycget', _get_eval_enc_str(index), "-#{key}")))
    end
  end
  def entryconfigure(index, key, val=None)
    if key.kind_of? Hash
      if (key['font'] || key[:font] || 
          key['kanjifont'] || key[:kanjifont] || 
          key['latinfont'] || key[:latinfont] || 
          key['asciifont'] || key[:asciifont])
        tagfont_configure(index, _symbolkey2str(key))
      else
        tk_send_without_enc('entryconfigure', _get_eval_enc_str(index), 
                            *hash_kv(key, true))
      end

    else
      if (key == 'font' || key == :font || 
          key == 'kanjifont' || key == :kanjifont || 
          key == 'latinfont' || key == :latinfont || 
          key == 'asciifont' || key == :asciifont )
        if val == None
          tagfontobj(index)
        else
          tagfont_configure(index, {key=>val})
        end
      else
        tk_call('entryconfigure', index, "-#{key}", val)
      end
    end
    self
  end

  def entryconfiginfo(index, key=nil)
    if TkComm::GET_CONFIGINFO_AS_ARRAY
      if key
        case key.to_s
        when 'text', 'label', 'show'
          conf = tk_split_simplelist(_fromUTF8(tk_send_without_enc('entryconfigure',_get_eval_enc_str(index),"-#{key}")))
        when 'font', 'kanjifont'
          conf = tk_split_simplelist(_fromUTF8(tk_send_without_enc('entryconfigure',_get_eval_enc_str(index),"-#{key}")))
          conf[4] = tagfont_configinfo(index, conf[4])
        else
          conf = tk_split_list(_fromUTF8(tk_send_without_enc('entryconfigure',_get_eval_enc_str(index),"-#{key}")))
        end
        conf[0] = conf[0][1..-1]
        conf
      else
        ret = tk_split_simplelist(_fromUTF8(tk_send_without_enc('entryconfigure', _get_eval_enc_str(index)))).collect{|conflist|
          conf = tk_split_simplelist(conflist)
          conf[0] = conf[0][1..-1]
          case conf[0]
          when 'text', 'label', 'show'
          else
            if conf[3]
              if conf[3].index('{')
                conf[3] = tk_split_list(conf[3]) 
              else
                conf[3] = tk_tcl2ruby(conf[3]) 
              end
            end
            if conf[4]
              if conf[4].index('{')
                conf[4] = tk_split_list(conf[4]) 
              else
                conf[4] = tk_tcl2ruby(conf[4]) 
              end
            end
          end
          conf[1] = conf[1][1..-1] if conf.size == 2 # alias info
          conf
        }
        if fontconf
          ret.delete_if{|item| item[0] == 'font' || item[0] == 'kanjifont'}
          fontconf[4] = tagfont_configinfo(index, fontconf[4])
          ret.push(fontconf)
        else
          ret
        end
      end
    else # ! TkComm::GET_CONFIGINFO_AS_ARRAY
      if key
        case key.to_s
        when 'text', 'label', 'show'
          conf = tk_split_simplelist(_fromUTF8(tk_send_without_enc('entryconfigure',_get_eval_enc_str(index),"-#{key}")))
        when 'font', 'kanjifont'
          conf = tk_split_simplelist(_fromUTF8(tk_send_without_enc('entryconfigure',_get_eval_enc_str(index),"-#{key}")))
          conf[4] = tagfont_configinfo(index, conf[4])
        else
          conf = tk_split_list(_fromUTF8(tk_send_without_enc('entryconfigure',_get_eval_enc_str(index),"-#{key}")))
        end
        key = conf.shift[1..-1]
        { key => conf }
      else
        ret = {}
        tk_split_simplelist(_fromUTF8(tk_send_without_enc('entryconfigure', _get_eval_enc_str(index)))).each{|conflist|
          conf = tk_split_simplelist(conflist)
          key = conf.shift[1..-1]
          case key
          when 'text', 'label', 'show'
          else
            if conf[2]
              if conf[2].index('{')
                conf[2] = tk_split_list(conf[2]) 
              else
                conf[2] = tk_tcl2ruby(conf[2]) 
              end
            end
            if conf[3]
              if conf[3].index('{')
                conf[3] = tk_split_list(conf[3]) 
              else
                conf[3] = tk_tcl2ruby(conf[3]) 
              end
            end
          end
          if conf.size == 1
            ret[key] = conf[0][1..-1]  # alias info
          else
            ret[key] = conf
          end
        }
        fontconf = ret['font']
        if fontconf
          ret.delete('font')
          ret.delete('kanjifont')
          fontconf[3] = tagfont_configinfo(index, fontconf[3])
          ret['font'] = fontconf
        end
        ret
      end
    end
  end

  def current_entryconfiginfo(index, key=nil)
    if TkComm::GET_CONFIGINFO_AS_ARRAY
      if key
        conf = entryconfiginfo(index, key)
        {conf[0] => conf[4]}
      else
        ret = {}
        entryconfiginfo(index).each{|conf|
          ret[conf[0]] = conf[4] if conf.size > 2
        }
        ret
      end
    else # ! TkComm::GET_CONFIGINFO_AS_ARRAY
      ret = {}
      entryconfiginfo(index, key).each{|k, conf|
        ret[k] = conf[-1] if conf.kind_of?(Array)
      }
      ret
    end
  end
=end
end


class TkMenuClone<TkMenu
  def initialize(parent, type=None)
    widgetname = nil
    if parent.kind_of? Hash
      keys = _symbolkey2str(parent)
      parent = keys.delete('parent')
      widgetname = keys.delete('widgetname')
      type = keys.delete('type'); type = None unless type
    end
    #unless parent.kind_of?(TkMenu)
    #  fail ArgumentError, "parent must be TkMenu"
    #end
    @parent = parent
    install_win(@parent.path, widgetname)
    tk_call_without_enc(@parent.path, 'clone', @path, type)
  end
end


module TkSystemMenu
  def initialize(parent, keys=nil)
    if parent.kind_of? Hash
      keys = _symbolkey2str(parent)
      parent = keys.delete('parent')
    end
    #unless parent.kind_of? TkMenu
    #  fail ArgumentError, "parent must be a TkMenu object"
    #end
    # @path = Kernel.format("%s.%s", parent.path, self.class::SYSMENU_NAME)
    @path = parent.path + '.' + self.class::SYSMENU_NAME
    #TkComm::Tk_WINDOWS[@path] = self
    TkCore::INTERP.tk_windows[@path] = self
    if self.method(:create_self).arity == 0
      p 'create_self has no arg' if $DEBUG
      create_self
      configure(keys) if keys
    else
      p 'create_self has an arg' if $DEBUG
      create_self(keys)
    end
  end
end


class TkSysMenu_Help<TkMenu
  # for all platform
  include TkSystemMenu
  SYSMENU_NAME = 'help'
end


class TkSysMenu_System<TkMenu
  # for Windows
  include TkSystemMenu
  SYSMENU_NAME = 'system'
end


class TkSysMenu_Apple<TkMenu
  # for Machintosh
  include TkSystemMenu
  SYSMENU_NAME = 'apple'
end


class TkMenubutton<TkLabel
  TkCommandNames = ['menubutton'.freeze].freeze
  WidgetClassName = 'Menubutton'.freeze
  WidgetClassNames[WidgetClassName] = self
  def create_self(keys)
    if keys and keys != None
      tk_call_without_enc('menubutton', @path, *hash_kv(keys, true))
    else
      tk_call_without_enc('menubutton', @path)
    end
  end
  private :create_self
end
TkMenuButton = TkMenubutton


class TkOptionMenubutton<TkMenubutton
  TkCommandNames = ['tk_optionMenu'.freeze].freeze

  class OptionMenu<TkMenu
    def initialize(path)  #==> return value of tk_optionMenu
      @path = path
      #TkComm::Tk_WINDOWS[@path] = self
      TkCore::INTERP.tk_windows[@path] = self
    end
  end

  def initialize(*args)
    # args :: [parent,] [var,] [value[, ...],] [keys]
    #    parent --> TkWindow or nil
    #    var    --> TkVariable or nil
    #    keys   --> Hash
    #       keys[:parent] or keys['parent']     --> parent
    #       keys[:variable] or keys['variable'] --> var
    #       keys[:values] or keys['values']     --> value, ...
    #       other Hash keys are menubutton options
    keys = {}
    keys = args.pop if args[-1].kind_of?(Hash)
    keys = _symbolkey2str(keys)

    parent = nil
    if args[0].kind_of?(TkWindow) || args[0] == nil
      parent = args.shift 
    else
      parent = keys.delete('parent')
    end

    @variable = nil
    if args[0].kind_of?(TkVariable) || args[0] == nil
      @variable = args.shift 
    else
      @variable = keys.delete('variable')
    end
    @variable = TkVariable.new unless @variable

    (args = keys.delete('values') || []) if args.empty?
    if args.empty?
      args << @variable.value
    else
      @variable.value = args[0]
    end

    install_win(if parent then parent.path end)
    @menu = OptionMenu.new(tk_call('tk_optionMenu', 
                                   @path, @variable.id, *args))

    configure(keys) if keys
  end

  def value
    @variable.value
  end

  def value=(val)
    @variable.value = val
  end

  def activate(index)
    @menu.activate(index)
    self
  end
  def add(value)
    @menu.add('radiobutton', 'variable'=>@variable, 
              'label'=>value, 'value'=>value)
    self
  end
  def index(index)
    @menu.index(index)
  end
  def invoke(index)
    @menu.invoke(index)
  end
  def insert(index, value)
    @menu.insert(index, 'radiobutton', 'variable'=>@variable, 
              'label'=>value, 'value'=>value)
    self
  end
  def delete(index, last=None)
    @menu.delete(index, last)
    self
  end
  def yposition(index)
    @menu.yposition(index)
  end
  def menu
    @menu
  end
  def menucget(key)
    @menu.cget(key)
  end
  def menuconfigure(key, val=None)
    @menu.configure(key, val)
    self
  end
  def menuconfiginfo(key=nil)
    @menu.configinfo(key)
  end
  def current_menuconfiginfo(key=nil)
    @menu.current_configinfo(key)
  end
  def entrycget(index, key)
    @menu.entrycget(index, key)
  end
  def entryconfigure(index, key, val=None)
    @menu.entryconfigure(index, key, val)
    self
  end
  def entryconfiginfo(index, key=nil)
    @menu.entryconfiginfo(index, key)
  end
  def current_entryconfiginfo(index, key=nil)
    @menu.current_entryconfiginfo(index, key)
  end
end
TkOptionMenuButton = TkOptionMenubutton
