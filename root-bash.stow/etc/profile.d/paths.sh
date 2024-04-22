if [ -d "$HOME/.local/bin" ]; then
	PATH="$PATH:$HOME/.local/bin"
fi

if [ -d "$HOME/.nimble/bin" ]; then
	PATH="$PATH:$HOME/.nimble/bin"
fi

if [ -d "$HOME/.cargo/bin" ]; then
	PATH="$PATH:$HOME/.cargo/bin"
fi
