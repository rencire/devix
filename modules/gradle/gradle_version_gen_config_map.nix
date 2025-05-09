{ pkgs, ... }:
{
  "8.8" = {
    version = "8.8";
    hash = "sha256-pLQVhgH4Y2ze6rCb12r7ZAAwu1sUSq/iYaXorwJ9xhI=";
    defaultJava = pkgs.jdk17;
  };
}
