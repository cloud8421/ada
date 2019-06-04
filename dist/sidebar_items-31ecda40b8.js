sidebarNodes={"extras":[{"id":"api-reference","title":"API Reference","group":"","headers":[{"id":"Modules","anchor":"modules"}]},{"id":"readme","title":"Ada","group":"","headers":[{"id":"Features","anchor":"features"},{"id":"Interaction modes","anchor":"interaction-modes"},{"id":"Setup","anchor":"setup"},{"id":"Data backups","anchor":"data-backups"},{"id":"Commit legend","anchor":"commit-legend"}]}],"exceptions":[],"modules":[{"id":"Ada.Schema.Frequency","title":"Ada.Schema.Frequency","group":"Core Schemas","nodeGroups":[{"key":"types","name":"Types","nodes":[{"id":"t/0","anchor":"t:t/0"}]},{"key":"functions","name":"Functions","nodes":[{"id":"changeset/2","anchor":"changeset/2"},{"id":"daily?/1","anchor":"daily?/1"},{"id":"hourly?/1","anchor":"hourly?/1"},{"id":"matches_time?/2","anchor":"matches_time?/2"},{"id":"weekly?/1","anchor":"weekly?/1"}]}]},{"id":"Ada.Schema.Location","title":"Ada.Schema.Location","group":"Core Schemas","nodeGroups":[{"key":"types","name":"Types","nodes":[{"id":"t/0","anchor":"t:t/0"}]},{"key":"functions","name":"Functions","nodes":[{"id":"changeset/2","anchor":"changeset/2"}]}]},{"id":"Ada.Schema.Preference","title":"Ada.Schema.Preference","group":"Core Schemas","nodeGroups":[{"key":"types","name":"Types","nodes":[{"id":"name/0","anchor":"t:name/0"},{"id":"t/0","anchor":"t:t/0"},{"id":"value/0","anchor":"t:value/0"}]},{"key":"functions","name":"Functions","nodes":[{"id":"changeset/2","anchor":"changeset/2"}]}]},{"id":"Ada.Schema.ScheduledTask","title":"Ada.Schema.ScheduledTask","group":"Core Schemas","nodeGroups":[{"key":"types","name":"Types","nodes":[{"id":"t/0","anchor":"t:t/0"}]},{"key":"functions","name":"Functions","nodes":[{"id":"changeset/2","anchor":"changeset/2"},{"id":"daily?/1","anchor":"daily?/1"},{"id":"hourly?/1","anchor":"hourly?/1"},{"id":"matches_time?/2","anchor":"matches_time?/2"},{"id":"preview/2","anchor":"preview/2"},{"id":"run/2","anchor":"run/2"},{"id":"weekly?/1","anchor":"weekly?/1"}]}]},{"id":"Ada.Schema.User","title":"Ada.Schema.User","group":"Core Schemas","nodeGroups":[{"key":"types","name":"Types","nodes":[{"id":"t/0","anchor":"t:t/0"}]},{"key":"functions","name":"Functions","nodes":[{"id":"changeset/2","anchor":"changeset/2"},{"id":"gravatar_url/1","anchor":"gravatar_url/1"}]}]},{"id":"Ada.Backup.Strategy","title":"Ada.Backup.Strategy","group":"Data backups","nodeGroups":[{"key":"types","name":"Types","nodes":[{"id":"contents/0","anchor":"t:contents/0"},{"id":"name/0","anchor":"t:name/0"},{"id":"path/0","anchor":"t:path/0"}]},{"key":"callbacks","name":"Callbacks","nodes":[{"id":"configured?/0","anchor":"c:configured?/0"},{"id":"download_file/1","anchor":"c:download_file/1"},{"id":"list_files/0","anchor":"c:list_files/0"},{"id":"upload_file/2","anchor":"c:upload_file/2"}]}]},{"id":"Ada.Backup.Uploader","title":"Ada.Backup.Uploader","group":"Data backups","nodeGroups":[{"key":"types","name":"Types","nodes":[{"id":"start_opts/0","anchor":"t:start_opts/0"}]},{"key":"functions","name":"Functions","nodes":[{"id":"child_spec/1","anchor":"child_spec/1"},{"id":"save_now/0","anchor":"save_now/0"},{"id":"save_today/0","anchor":"save_today/0"},{"id":"start_link/1","anchor":"start_link/1"}]}]},{"id":"Ada.CRUD","title":"Ada.CRUD","group":"Data management","nodeGroups":[{"key":"types","name":"Types","nodes":[{"id":"ctx/0","anchor":"t:ctx/0"},{"id":"resource/0","anchor":"t:resource/0"},{"id":"resource_id/0","anchor":"t:resource_id/0"},{"id":"schema/0","anchor":"t:schema/0"}]},{"key":"functions","name":"Functions","nodes":[{"id":"create/3","anchor":"create/3"},{"id":"delete/2","anchor":"delete/2"},{"id":"find/3","anchor":"find/3"},{"id":"list/2","anchor":"list/2"},{"id":"update/4","anchor":"update/4"}]}]},{"id":"Ada.Preferences","title":"Ada.Preferences","group":"Data management","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"id":"all/0","anchor":"all/0"},{"id":"cast/1","anchor":"cast/1"},{"id":"get/1","anchor":"get/1"},{"id":"load_defaults!/0","anchor":"load_defaults!/0"},{"id":"set/2","anchor":"set/2"}]}]},{"id":"Ada.Display","title":"Ada.Display","group":"Display management","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"id":"callback_mode/0","anchor":"callback_mode/0"},{"id":"child_spec/1","anchor":"child_spec/1"},{"id":"cyclic/3","anchor":"cyclic/3"},{"id":"get_brightness/0","anchor":"get_brightness/0"},{"id":"init/1","anchor":"init/1"},{"id":"is_valid_cycle_spec/1","anchor":"is_valid_cycle_spec/1"},{"id":"off/3","anchor":"off/3"},{"id":"set_brightness/1","anchor":"set_brightness/1"},{"id":"set_content/1","anchor":"set_content/1"},{"id":"start_link/1","anchor":"start_link/1"},{"id":"static/3","anchor":"static/3"},{"id":"turn_off/0","anchor":"turn_off/0"},{"id":"turn_on/0","anchor":"turn_on/0"}]}]},{"id":"Ada.Display.Driver","title":"Ada.Display.Driver","group":"Display management","nodeGroups":[{"key":"types","name":"Types","nodes":[{"id":"brightness/0","anchor":"t:brightness/0"},{"id":"buffer/0","anchor":"t:buffer/0"}]},{"key":"callbacks","name":"Callbacks","nodes":[{"id":"default_content/0","anchor":"c:default_content/0"},{"id":"set_brightness/1","anchor":"c:set_brightness/1"},{"id":"set_buffer/1","anchor":"c:set_buffer/1"},{"id":"set_default_brightness/0","anchor":"c:set_default_brightness/0"}]}]},{"id":"Ada.Email","title":"Ada.Email","group":"Email","nodeGroups":[{"key":"types","name":"Types","nodes":[{"id":"t/0","anchor":"t:t/0"}]}]},{"id":"Ada.Email.Adapter","title":"Ada.Email.Adapter","group":"Email","nodeGroups":[{"key":"callbacks","name":"Callbacks","nodes":[{"id":"send_email/1","anchor":"c:send_email/1"}]}]},{"id":"Ada.Email.Adapter.Sendgrid","title":"Ada.Email.Adapter.Sendgrid","group":"Email","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"id":"to_payload/1","anchor":"to_payload/1"}]}]},{"id":"Ada.Email.Quickchart","title":"Ada.Email.Quickchart","group":"Email","nodeGroups":[{"key":"types","name":"Types","nodes":[{"id":"chart_type/0","anchor":"t:chart_type/0"},{"id":"data/0","anchor":"t:data/0"},{"id":"dataset/0","anchor":"t:dataset/0"},{"id":"dimension/0","anchor":"t:dimension/0"},{"id":"label/0","anchor":"t:label/0"},{"id":"t/0","anchor":"t:t/0"}]},{"key":"functions","name":"Functions","nodes":[{"id":"add_dataset/3","anchor":"add_dataset/3"},{"id":"add_labels/2","anchor":"add_labels/2"},{"id":"new/1","anchor":"new/1"},{"id":"set_dimensions/3","anchor":"set_dimensions/3"},{"id":"to_url/1","anchor":"to_url/1"}]}]},{"id":"Ada.HTTP.Client","title":"Ada.HTTP.Client","group":"External services","nodeGroups":[{"key":"types","name":"Types","nodes":[{"id":"headers/0","anchor":"t:headers/0"}]},{"key":"functions","name":"Functions","nodes":[{"id":"delete/2","anchor":"delete/2"},{"id":"get/3","anchor":"get/3"},{"id":"json_get/3","anchor":"json_get/3"},{"id":"json_post/3","anchor":"json_post/3"},{"id":"json_put/3","anchor":"json_put/3"},{"id":"post/4","anchor":"post/4"},{"id":"put/4","anchor":"put/4"}]}]},{"id":"Ada.Workflow","title":"Ada.Workflow","group":"Workflows","nodeGroups":[{"key":"types","name":"Types","nodes":[{"id":"ctx/0","anchor":"t:ctx/0"},{"id":"raw_data/0","anchor":"t:raw_data/0"},{"id":"raw_data_result/0","anchor":"t:raw_data_result/0"},{"id":"requirements/0","anchor":"t:requirements/0"},{"id":"run_result/0","anchor":"t:run_result/0"},{"id":"t/0","anchor":"t:t/0"},{"id":"transport/0","anchor":"t:transport/0"},{"id":"validation_errors/0","anchor":"t:validation_errors/0"}]},{"key":"functions","name":"Functions","nodes":[{"id":"normalize_name/1","anchor":"normalize_name/1"},{"id":"raw_data/3","anchor":"raw_data/3"},{"id":"run/4","anchor":"run/4"},{"id":"transports/0","anchor":"transports/0"},{"id":"valid_name?/1","anchor":"valid_name?/1"},{"id":"validate/2","anchor":"validate/2"}]},{"key":"callbacks","name":"Callbacks","nodes":[{"id":"fetch/2","anchor":"c:fetch/2"},{"id":"format/3","anchor":"c:format/3"},{"id":"human_name/0","anchor":"c:human_name/0"},{"id":"requirements/0","anchor":"c:requirements/0"}]}]},{"id":"Ada.CLI","title":"Ada.CLI","group":"CLI","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"id":"commands/0","anchor":"commands/0"},{"id":"default_command/0","anchor":"default_command/0"},{"id":"main/1","anchor":"main/1"},{"id":"name/0","anchor":"name/0"}]}]},{"id":"Ada.CLI.FishCompletion","title":"Ada.CLI.FishCompletion","group":"CLI","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"id":"render/0","anchor":"render/0"}]}]},{"id":"Ada.CLI.Format.HTML","title":"Ada.CLI.Format.HTML","group":"CLI","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"id":"pp/1","anchor":"pp/1"}]}]},{"id":"Ada.CLI.Helpers","title":"Ada.CLI.Helpers","group":"CLI","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"id":"connect!/2","anchor":"connect!/2"},{"id":"ensure_location_dependencies!/0","anchor":"ensure_location_dependencies!/0"},{"id":"get_current_location_data/0","anchor":"get_current_location_data/0"}]}]},{"id":"Ada.CLI.Markup","title":"Ada.CLI.Markup","group":"CLI","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"id":"bar/1","anchor":"bar/1"},{"id":"break/0","anchor":"break/0"},{"id":"dash/0","anchor":"dash/0"},{"id":"double_title/3","anchor":"double_title/3"},{"id":"ellipsis/2","anchor":"ellipsis/2"},{"id":"emdash/0","anchor":"emdash/0"},{"id":"h1/1","anchor":"h1/1"},{"id":"h2/1","anchor":"h2/1"},{"id":"h3/1","anchor":"h3/1"},{"id":"left_pad/0","anchor":"left_pad/0"},{"id":"list_item/2","anchor":"list_item/2"},{"id":"p/2","anchor":"p/2"},{"id":"primary/1","anchor":"primary/1"},{"id":"secondary/1","anchor":"secondary/1"},{"id":"space/0","anchor":"space/0"},{"id":"tertiary/1","anchor":"tertiary/1"},{"id":"title/1","anchor":"title/1"},{"id":"wrap/2","anchor":"wrap/2"}]}]},{"id":"Logger.Backends.Telegraf","title":"Logger.Backends.Telegraf","group":"Metrics and logs","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"id":"handle_call/2","anchor":"handle_call/2"},{"id":"handle_event/2","anchor":"handle_event/2"},{"id":"init/1","anchor":"init/1"}]}]},{"id":"Ada.PubSub","title":"Ada.PubSub","group":"Utilities","nodeGroups":[{"key":"functions","name":"Functions","nodes":[{"id":"publish/2","anchor":"publish/2"},{"id":"subscribe/1","anchor":"subscribe/1"}]}]}],"tasks":[]}