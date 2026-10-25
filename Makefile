# One-time setup: adds the coolblue-analytics-engineer alias to your .zshrc, if it isn't
# already there. Safe to run more than once (won't duplicate the line).
install-alias:
	@if ! grep -qF 'alias coolblue-analytics-engineer=' ~/.zshrc 2>/dev/null; then \
		echo '' >> ~/.zshrc; \
		echo '# Jumps into the coolblue-analytics-engineer project and activates its virtual environment' >> ~/.zshrc; \
		echo 'alias coolblue-analytics-engineer="cd ~/projects/coolblue-analytics-engineer-sara-garcia-cabezali && source .venv/bin/activate"' >> ~/.zshrc; \
		echo "Alias added to ~/.zshrc"; \
	else \
		echo "Alias already present in ~/.zshrc — skipping"; \
	fi
	@echo "Run 'source ~/.zshrc' (or open a new terminal) to start using it."
