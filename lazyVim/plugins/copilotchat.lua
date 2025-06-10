return {
  "CopilotC-Nvim/CopilotChat.nvim",
  -- LazyVim의 기본 설정을 유지하면서, 사용자 정의 opts만 추가하려면
  -- 다음처럼 빈 opts 테이블을 선언하고 필요한 설정을 추가합니다.
  -- 만약 이 플러그인의 다른 설정이 없다면, 이 파일이 로드될 때
  -- 기존 LazyVim의 기본 설정과 병합되어 사용됩니다.
  opts = {
    -- 다른 CopilotChat 설정을 여기에 추가할 수 있습니다.
    -- 예를 들어:
    -- show_thought = true,

    -- 반드시 필요한 python_host 설정
    -- 이 경로는 이전에 가상 환경을 만든 경로에 따라 다릅니다.
    python_host = vim.fn.expand("~/.config/nvim/venv_copilotchat/bin/python"),
    verbose = true, -- 이 라인을 추가
  },
  -- config 함수는 LazyVim이 자동으로 호출하므로 별도로 명시하지 않아도 됩니다.
  -- 하지만 명시적으로 설정 함수를 쓰고 싶다면 다음과 같이 할 수 있습니다.
  config = function(_, opts)
    require("CopilotChat").setup(opts)
  end,
}
