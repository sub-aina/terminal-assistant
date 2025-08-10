# ~/terminal-assistant/backend/terminal_assistant_completion.bash

_terminal_assistant_complete() {
    local current_word="${COMP_WORDS[COMP_CWORD]}"
    local current_line="${COMP_LINE}"
    
  
    if [[ ${#current_line} -lt 3 ]]; then
        return
    fi
    
    local encoded_cmd=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$current_line'))" 2>/dev/null)
    
 
    if [[ -z "$encoded_cmd" ]]; then
        encoded_cmd="${current_line// /%20}"
    fi
    
  
    local completion_response=$(curl -s -m 2 "http://localhost:8000/complete?partial_command=$encoded_cmd" 2>/dev/null)
    
    if [[ $? -eq 0 && -n "$completion_response" ]]; then
      
        local full_completion
        
        if command -v jq >/dev/null 2>&1; then
            full_completion=$(echo "$completion_response" | jq -r '.completion // empty' 2>/dev/null)
        else
           
            full_completion=$(echo "$completion_response" | grep -o '"completion":"[^"]*"' | cut -d'"' -f4)
        fi
        
        if [[ -n "$full_completion" && "$full_completion" != "$current_line" ]]; then
           
            local completion_words=($full_completion)
            local current_words=($current_line)
            local remaining_words=()
       
            local i=${#current_words[@]}
            while [[ $i -lt ${#completion_words[@]} ]]; do
                remaining_words+=("${completion_words[$i]}")
                ((i++))
            done
            
        
            if [[ ${#remaining_words[@]} -gt 0 ]]; then
             
                local last_current_word="${current_words[-1]}"
                local first_remaining_word="${completion_words[${#current_words[@]}-1]}"
                
              
                if [[ "$first_remaining_word" == "$last_current_word"* ]]; then
                    COMPREPLY=("$first_remaining_word")
                else
                  
                    COMPREPLY=("${remaining_words[0]}")
                fi
            else
               
                local last_word="${current_words[-1]}"
                local completion_last_word="${completion_words[-1]}"
                if [[ "$completion_last_word" == "$last_word"* && "$completion_last_word" != "$last_word" ]]; then
                    COMPREPLY=("$completion_last_word")
                fi
            fi
            return
        fi
    fi
 
    COMPREPLY=()
}

complete -F _terminal_assistant_complete git
complete -F _terminal_assistant_complete docker  
complete -F _terminal_assistant_complete npm
complete -F _terminal_assistant_complete python
complete -F _terminal_assistant_complete python3
complete -F _terminal_assistant_complete curl
complete -F _terminal_assistant_complete ssh
complete -F _terminal_assistant_complete kubectl
complete -F _terminal_assistant_complete systemctl

echo "Terminal Assistant completion loaded!"