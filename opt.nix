#MC # opt.nix
#MC
#MC nix语言中只有`let ... in`来定义局部变量，没有提供全局变量的语法支持。
#MC 但在我的nix配置中又很需要一些“全局变量”来方便统一的管理多个配置文件。
#MC 有2种可行的方案来实现全局变量：module和import。
#MC
#MC ## module
#MC
#MC nixpkgs的module能够还不错地实现“全局变量”。
#MC 想了解module？可以去看看[NixOS wikiL modules](https://nixos.wiki/wiki/NixOS_modules)。
#MC 或者看看nixpkgs源码关于modules.nix的部分`<nixpkgs>/lib/modules.nix`。
#MC
#MC 要注意的是，基于module的“全局变量”也会有<span style="color:red;">**局限**</span>的。
#MC module是用过imports变量导入的，若在imports语句访问“全局变量”，nix的lazy evaluation的特性会导致死循环。
#MC 这也是为什么老版本的[home.nix](./home.nix.md)中判断是否需要导入[./usr/gui.nix](./usr/gui.nix.md)，
#MC 我没有使用`config.isGui`而是再次使用getEnv访问环境变量。
#MC 当然这个不足也是我放弃使用的module主要原因。
#MC
#MC ## import
#MC
#MC 通过在配置文件中import opt.nix也能还不错的实现“全局变量”。
#MC import方法的最大优势是能够在module imports语句中避免死循环。
#MC
#MC 这个方法的不足之处在于每个需要使用全局变量的文件都需要import opt.nix。
#MC 但这个不方便之处，相对imports死循环，没那么让人难受。
{
  isMinimalConfig = false;
  #MC `proxyPort`：代理端口号，诸多网络程序需要用，比如clash和tailscale。
  proxyPort = 8889;
  #MC `isCli`和`isGui`：通过环境变量`DISPLAY`来判断是否是CLI或GUI环境。
  #MC 这个方法有<span style="color:red;">**局限**</span>，比如ssh连接到一台有GUI的电脑上，ssh里是没有设置环境变量`DISPLAY`的。
  #MC 因此更好的方法是在opt-local.nix中写入固定的isCli和isGui值。
  isCli = (builtins.getEnv "DISPLAY")=="";
  isGui = (builtins.getEnv "DISPLAY")!="";
  #MC `isNixOnDroid`：通过用户名来判断是否是nix-on-droid。
  isNixOnDroid = (builtins.getEnv "USER")=="nix-on-droid";
  #MC `isWSL2`：通过环境变量`WSL_DISTRO_NAME`来判断是否是WSL2。
  isWSL2 = (builtins.getEnv "WSL_DISTRO_NAME")!="";
}
#MC ### 本地配置
#MC
#MC 引入opt-local.nix，方便本地进行自定义，避免我的nix配置中出现过多设备特定代码（即一堆if else判断语句）。
#MC 为了减少设备特定代码，每个设备都有自己的opt-local.nix。
#MC 目前的想法是不将opt-local.nix加入git仓库，以实现“设备特定”。
#MC 相比opt.nix，opt-local.nix的配置具备更高的优先级。
// (
  if (builtins.pathExists ./opt-local.nix)
  then import ./opt-local.nix
  else {}
)
