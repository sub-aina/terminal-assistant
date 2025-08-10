import * as vscode from 'vscode';
// Remove: import fetch from 'node-fetch';

export function activate(context: vscode.ExtensionContext) {
    // Register inline completion provider for shell files
    context.subscriptions.push(
        vscode.languages.registerInlineCompletionItemProvider({ pattern: '**' }, {
            async provideInlineCompletionItems(document, position, context, token) {
                const line = document.lineAt(position).text;
                if (line.trim().length < 3) return [];

                try {
                    const fetch = (await import('node-fetch')).default;
                    const res = await fetch(`http://localhost:8000/complete?partial_command=${encodeURIComponent(line)}`);
                    const data = await res.json() as { completion: string };
                    const completion = data.completion;

                    if (!completion || completion.trim() === line.trim()) return [];

                    return [
                        {
                            insertText: completion.slice(line.length),
                            range: new vscode.Range(position, position)
                        }
                    ];
                } catch (err) {
                    return [];
                }
            }
        })
    );

    // Command to explain the current terminal command
    context.subscriptions.push(
        vscode.commands.registerCommand('terminal-assistant.explainCommand', async () => {
            const editor = vscode.window.activeTextEditor;
            if (!editor) return;

            const selection = editor.document.getText(editor.selection) || editor.document.lineAt(editor.selection.active).text;
            const fetch = (await import('node-fetch')).default;
            const res = await fetch(`http://localhost:8000/explain`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ command: selection })
            });
          const data = await res.json() as { explanation: string };
          vscode.window.showInformationMessage(`💡 ${data.explanation}`);

        })
    );
}

export function deactivate() {}