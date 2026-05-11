proc bail {msg} {
    puts stderr "\n\[FAIL\] $msg"
    if {[info exists ::log_path] && $::log_path ne ""} {
        puts stderr "Log: $::log_path"
    }
    exit 1
}

proc send_cmd {cmd} {
    send -- "$cmd\r"
    sleep 0.3
}

proc wait_for {desc pattern {timeout_s 60}} {
    set timeout $timeout_s
    expect {
        -re $pattern {
            puts "\[OK\]   $desc"
            return $expect_out(0,string)
        }
        timeout {
            bail "$desc -- timed out after ${timeout_s}s waiting for: $pattern"
        }
        eof {
            bail "$desc -- process exited unexpectedly"
        }
    }
}

proc check_cmd {desc cmd expected} {
    send_cmd $cmd
    wait_for $desc $expected
}

proc desc_to_re {text} {
    set escaped [string map {
        "\\" "\\\\" "." "\\." "*" "\\*" "+" "\\+"
        "?" "\\?" "\[" "\\\[" "\]" "\\\]" "(" "\\("
        ")" "\\)" "{" "\\{" "}" "\\}" "^" "\\^"
        "$" "\\$" "|" "\\|"
    } $text]
    regsub -all {\s+} $escaped {.*?} re
    return $re
}
