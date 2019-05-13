searchNodes=[{"ref":"Ada.Schema.Frequency.html","title":"Ada.Schema.Frequency","type":"module","doc":"The module expresses the idea of something that can be repeated at regular intervals. While it&#39;s used mainly with Ada.Schema.ScheduledTask, it can be applied to other use cases. See t/0 for details."},{"ref":"Ada.Schema.Frequency.html#changeset/2","title":"Ada.Schema.Frequency.changeset/2","type":"function","doc":"Returns a changeset, starting from a frequency and a map of attributes to change."},{"ref":"Ada.Schema.Frequency.html#daily?/1","title":"Ada.Schema.Frequency.daily?/1","type":"function","doc":"Returns true for a daily frequency."},{"ref":"Ada.Schema.Frequency.html#hourly?/1","title":"Ada.Schema.Frequency.hourly?/1","type":"function","doc":"Returns true for a hourly frequency."},{"ref":"Ada.Schema.Frequency.html#matches_time?/2","title":"Ada.Schema.Frequency.matches_time?/2","type":"function","doc":"Returns true for a frequency that matches a given datetime, where matching is defined as: same day of the week, hour and zero minutes and seconds for a weekly frequency same hour, same minute and zero seconds for a daily frequency same minute and second for a hourly frequency"},{"ref":"Ada.Schema.Frequency.html#weekly?/1","title":"Ada.Schema.Frequency.weekly?/1","type":"function","doc":"Returns true for a weekly frequency."},{"ref":"Ada.Schema.Frequency.html#t:t/0","title":"Ada.Schema.Frequency.t/0","type":"type","doc":"A frequency is determined by a type (hourly, daily or weekly) and day of the week, hour, minute and second. Depending on the type, some fields are irrelevant (e.g. minutes for a weekly frequency)."},{"ref":"Ada.Schema.Location.html","title":"Ada.Schema.Location","type":"module","doc":"Represents a location (e.g. home or office). See t/0 for details."},{"ref":"Ada.Schema.Location.html#changeset/2","title":"Ada.Schema.Location.changeset/2","type":"function","doc":"Returns a changeset, starting from a location and a map of attributes to change."},{"ref":"Ada.Schema.Location.html#t:t/0","title":"Ada.Schema.Location.t/0","type":"type","doc":"A location is defined primarily by a name and its lat/lng coordinates."},{"ref":"Ada.Schema.Preference.html","title":"Ada.Schema.Preference","type":"module","doc":"A preference is a pair of key, value settings which affect the behaviour of the entire application. One example is the preferred timezone."},{"ref":"Ada.Schema.Preference.html#changeset/2","title":"Ada.Schema.Preference.changeset/2","type":"function","doc":"Returns a changeset, starting from a preference and a map of attributes to change."},{"ref":"Ada.Schema.Preference.html#t:name/0","title":"Ada.Schema.Preference.name/0","type":"type","doc":""},{"ref":"Ada.Schema.Preference.html#t:t/0","title":"Ada.Schema.Preference.t/0","type":"type","doc":""},{"ref":"Ada.Schema.Preference.html#t:value/0","title":"Ada.Schema.Preference.value/0","type":"type","doc":""},{"ref":"Ada.Schema.ScheduledTask.html","title":"Ada.Schema.ScheduledTask","type":"module","doc":"Represents a boilerplate for the recurring execution of a workflow. Captures the workflow to run, its frequency and params. See t/0 for more details."},{"ref":"Ada.Schema.ScheduledTask.html#changeset/2","title":"Ada.Schema.ScheduledTask.changeset/2","type":"function","doc":"Returns a changeset, starting from a scheduled task and a map of attributes to change."},{"ref":"Ada.Schema.ScheduledTask.html#daily?/1","title":"Ada.Schema.ScheduledTask.daily?/1","type":"function","doc":"Returns true for a daily task."},{"ref":"Ada.Schema.ScheduledTask.html#hourly?/1","title":"Ada.Schema.ScheduledTask.hourly?/1","type":"function","doc":"Returns true for an hourly task."},{"ref":"Ada.Schema.ScheduledTask.html#matches_time?/2","title":"Ada.Schema.ScheduledTask.matches_time?/2","type":"function","doc":"Returns true for a task that matches a given datetime, where matching is defined as: same day of the week, hour and zero minutes and seconds for a weekly task same hour, same minute and zero seconds for a daily task same minute and second for a hourly task"},{"ref":"Ada.Schema.ScheduledTask.html#preview/2","title":"Ada.Schema.ScheduledTask.preview/2","type":"function","doc":"Previews the results of a scheduled task by looking at its raw data."},{"ref":"Ada.Schema.ScheduledTask.html#run/2","title":"Ada.Schema.ScheduledTask.run/2","type":"function","doc":"Runs a scheduled task resolving the contained workflow."},{"ref":"Ada.Schema.ScheduledTask.html#weekly?/1","title":"Ada.Schema.ScheduledTask.weekly?/1","type":"function","doc":"Returns true for a weekly task."},{"ref":"Ada.Schema.ScheduledTask.html#t:t/0","title":"Ada.Schema.ScheduledTask.t/0","type":"type","doc":"A scheduled task is mainly defined by: a workflow name, deciding the workflow that needs to be run a frequency, determining how often the task is run (see Ada.Schema.Frequency) a map of params, which are going to be passed to the workflow when run a transport, deciding the transport used to communicate the workflow result to the relevant user"},{"ref":"Ada.Schema.User.html","title":"Ada.Schema.User","type":"module","doc":"Represents a system user, identified by a numeric ID. Fields are defined in combination with workflows (see Ada.Worfklow)"},{"ref":"Ada.Schema.User.html#changeset/2","title":"Ada.Schema.User.changeset/2","type":"function","doc":"Returns a changeset starting from a user and a map of attributes to set."},{"ref":"Ada.Schema.User.html#gravatar_url/1","title":"Ada.Schema.User.gravatar_url/1","type":"function","doc":"Given a user, returns their gravatar url."},{"ref":"Ada.Schema.User.html#t:t/0","title":"Ada.Schema.User.t/0","type":"type","doc":""},{"ref":"Ada.Backup.Strategy.html","title":"Ada.Backup.Strategy","type":"behaviour","doc":"The Ada.Backup.Strategy behaviour defines a module capable of backing up and restoring files from a specific provider."},{"ref":"Ada.Backup.Strategy.html#c:configured?/0","title":"Ada.Backup.Strategy.configured?/0","type":"callback","doc":"This callback should check if the module is properly setup, e.g. if any access token is present. The function will be invoked at application boot. If it returns false, backups will be disabled."},{"ref":"Ada.Backup.Strategy.html#c:download_file/1","title":"Ada.Backup.Strategy.download_file/1","type":"callback","doc":"Download a file at a given path, returning its contents."},{"ref":"Ada.Backup.Strategy.html#c:list_files/0","title":"Ada.Backup.Strategy.list_files/0","type":"callback","doc":"Returns a list of paths where backups are stored. Each one of these paths should be compatible with the download_file/1 callback."},{"ref":"Ada.Backup.Strategy.html#c:upload_file/2","title":"Ada.Backup.Strategy.upload_file/2","type":"callback","doc":"Uploads a file with the specified contents under the given name, returning its path."},{"ref":"Ada.Backup.Strategy.html#t:contents/0","title":"Ada.Backup.Strategy.contents/0","type":"type","doc":"The contents of the backup file"},{"ref":"Ada.Backup.Strategy.html#t:name/0","title":"Ada.Backup.Strategy.name/0","type":"type","doc":"The name to use when saving the file"},{"ref":"Ada.Backup.Strategy.html#t:path/0","title":"Ada.Backup.Strategy.path/0","type":"type","doc":"The path where a backup is stored"},{"ref":"Ada.Backup.Uploader.html","title":"Ada.Backup.Uploader","type":"module","doc":"Controls the upload of the database file to the configured backup location."},{"ref":"Ada.Backup.Uploader.html#child_spec/1","title":"Ada.Backup.Uploader.child_spec/1","type":"function","doc":"Returns a specification to start this module under a supervisor. See Supervisor."},{"ref":"Ada.Backup.Uploader.html#save_now/0","title":"Ada.Backup.Uploader.save_now/0","type":"function","doc":"Saves a copy of the database, naming it with the current timestamp."},{"ref":"Ada.Backup.Uploader.html#save_today/0","title":"Ada.Backup.Uploader.save_today/0","type":"function","doc":"Saves a copy of the database, naming it with today&#39;s date."},{"ref":"Ada.Backup.Uploader.html#start_link/1","title":"Ada.Backup.Uploader.start_link/1","type":"function","doc":"Starts the uploaded process. Requires a strategy."},{"ref":"Ada.Backup.Uploader.html#t:start_opts/0","title":"Ada.Backup.Uploader.start_opts/0","type":"type","doc":""},{"ref":"Ada.CRUD.html","title":"Ada.CRUD","type":"module","doc":"This module collects generalised ways to manage database entries."},{"ref":"Ada.CRUD.html#create/3","title":"Ada.CRUD.create/3","type":"function","doc":"Create a new resource."},{"ref":"Ada.CRUD.html#delete/2","title":"Ada.CRUD.delete/2","type":"function","doc":"Delete a resource."},{"ref":"Ada.CRUD.html#find/3","title":"Ada.CRUD.find/3","type":"function","doc":"Find a resource by its ID."},{"ref":"Ada.CRUD.html#list/2","title":"Ada.CRUD.list/2","type":"function","doc":"List all resources of the same type."},{"ref":"Ada.CRUD.html#update/4","title":"Ada.CRUD.update/4","type":"function","doc":"Update an existing resource."},{"ref":"Ada.CRUD.html#t:ctx/0","title":"Ada.CRUD.ctx/0","type":"type","doc":""},{"ref":"Ada.CRUD.html#t:resource/0","title":"Ada.CRUD.resource/0","type":"type","doc":""},{"ref":"Ada.CRUD.html#t:resource_id/0","title":"Ada.CRUD.resource_id/0","type":"type","doc":""},{"ref":"Ada.CRUD.html#t:schema/0","title":"Ada.CRUD.schema/0","type":"type","doc":""},{"ref":"Ada.Preferences.html","title":"Ada.Preferences","type":"module","doc":"Control system wide preferences."},{"ref":"Ada.Preferences.html#all/0","title":"Ada.Preferences.all/0","type":"function","doc":"Returns all existing preferences as tuples."},{"ref":"Ada.Preferences.html#cast/1","title":"Ada.Preferences.cast/1","type":"function","doc":"Safely cast a preference name to its atom form."},{"ref":"Ada.Preferences.html#get/1","title":"Ada.Preferences.get/1","type":"function","doc":"Returns the value of a given preference."},{"ref":"Ada.Preferences.html#load_defaults!/0","title":"Ada.Preferences.load_defaults!/0","type":"function","doc":"Loads default values in the database without overwriting already existing entries."},{"ref":"Ada.Preferences.html#set/2","title":"Ada.Preferences.set/2","type":"function","doc":"Sets the value of a given preference."},{"ref":"Ada.Display.html","title":"Ada.Display","type":"module","doc":"Supports the following contents: Static Ada.Display.set_content({:static, Ada.UI.Helpers.chars_to_matrix(&#39;1234&#39;)}) Cyclic Ada.Display.set_content( {:cycle, [ {Ada.UI.Helpers.chars_to_matrix(&#39;A &#39;), 200}, {Ada.UI.Helpers.chars_to_matrix(&#39; A &#39;), 200}, {Ada.UI.Helpers.chars_to_matrix(&#39; A &#39;), 200}, {Ada.UI.Helpers.chars_to_matrix(&#39; A&#39;), 200} ]} )"},{"ref":"Ada.Display.html#callback_mode/0","title":"Ada.Display.callback_mode/0","type":"function","doc":"Callback implementation for c::gen_statem.callback_mode/0."},{"ref":"Ada.Display.html#child_spec/1","title":"Ada.Display.child_spec/1","type":"function","doc":""},{"ref":"Ada.Display.html#cyclic/3","title":"Ada.Display.cyclic/3","type":"function","doc":""},{"ref":"Ada.Display.html#get_brightness/0","title":"Ada.Display.get_brightness/0","type":"function","doc":""},{"ref":"Ada.Display.html#init/1","title":"Ada.Display.init/1","type":"function","doc":"Callback implementation for c::gen_statem.init/1."},{"ref":"Ada.Display.html#is_valid_cycle_spec/1","title":"Ada.Display.is_valid_cycle_spec/1","type":"macro","doc":""},{"ref":"Ada.Display.html#off/3","title":"Ada.Display.off/3","type":"function","doc":""},{"ref":"Ada.Display.html#set_brightness/1","title":"Ada.Display.set_brightness/1","type":"function","doc":""},{"ref":"Ada.Display.html#set_content/1","title":"Ada.Display.set_content/1","type":"function","doc":""},{"ref":"Ada.Display.html#start_link/1","title":"Ada.Display.start_link/1","type":"function","doc":""},{"ref":"Ada.Display.html#static/3","title":"Ada.Display.static/3","type":"function","doc":""},{"ref":"Ada.Display.html#turn_off/0","title":"Ada.Display.turn_off/0","type":"function","doc":""},{"ref":"Ada.Display.html#turn_on/0","title":"Ada.Display.turn_on/0","type":"function","doc":""},{"ref":"Ada.Display.Driver.html","title":"Ada.Display.Driver","type":"behaviour","doc":"This behaviour represents a generic display driver, which needs to be implemented when supporting a new LED display or similar."},{"ref":"Ada.Display.Driver.html#c:default_content/0","title":"Ada.Display.Driver.default_content/0","type":"callback","doc":"Returns the buffer that should be set when the display is turned on."},{"ref":"Ada.Display.Driver.html#c:set_brightness/1","title":"Ada.Display.Driver.set_brightness/1","type":"callback","doc":"Synchronously set the current brightness, so that the display can be updated."},{"ref":"Ada.Display.Driver.html#c:set_buffer/1","title":"Ada.Display.Driver.set_buffer/1","type":"callback","doc":"Synchronously set the current buffer, so that it can be displayed."},{"ref":"Ada.Display.Driver.html#c:set_default_brightness/0","title":"Ada.Display.Driver.set_default_brightness/0","type":"callback","doc":"Sets the default brightness that&#39;s used when the display is turned on."},{"ref":"Ada.Display.Driver.html#t:brightness/0","title":"Ada.Display.Driver.brightness/0","type":"type","doc":"Represents the brigthness of the display, from low (1) to high (255)."},{"ref":"Ada.Display.Driver.html#t:buffer/0","title":"Ada.Display.Driver.buffer/0","type":"type","doc":"A data structure representing the contents of the display."},{"ref":"Ada.Email.html","title":"Ada.Email","type":"module","doc":"Represents an email that can be sent via different adapters."},{"ref":"Ada.Email.html#t:t/0","title":"Ada.Email.t/0","type":"type","doc":""},{"ref":"Ada.Email.Adapter.html","title":"Ada.Email.Adapter","type":"behaviour","doc":"An email adapter takes a Ada.Email.t/0 and sends it, reporting the result."},{"ref":"Ada.Email.Adapter.html#c:send_email/1","title":"Ada.Email.Adapter.send_email/1","type":"callback","doc":"Synchronously sends an email."},{"ref":"Ada.Email.Adapter.Sendgrid.html","title":"Ada.Email.Adapter.Sendgrid","type":"module","doc":"Implements the Ada.Email.Adapter behaviour on top of the Sendgrid API (documentation available at https://sendgrid.com/docs/API_Reference/api_v3.html)."},{"ref":"Ada.Email.Adapter.Sendgrid.html#to_payload/1","title":"Ada.Email.Adapter.Sendgrid.to_payload/1","type":"function","doc":"Converts an email to a sendgrid payload that can be POSTed directly. iex&gt; alias Ada.Email iex&gt; alias Email.Adapter.Sendgrid iex&gt; %Email{to: [&quot;user@example.com&quot;], cc: [&quot;cc@example.com&quot;], bcc: [&quot;bcc@example.com&quot;], reply_to: &quot;reply@example.com&quot;} ...&gt; |&gt; Sendgrid.to_payload %{personalizations: [%{to: [%{email: &quot;user@example.com&quot;}], cc: [%{email: &quot;cc@example.com&quot;}], bcc: [%{email: &quot;bcc@example.com&quot;}], subject: &quot;default email subject&quot;}], from: %{email: &quot;ada@fullyforged.com&quot;, name: &quot;Ada&quot;}, reply_to: %{email: &quot;reply@example.com&quot;}, content: [%{type: &quot;text/plain&quot;, value: &quot;Plain text default body&quot;}, %{type: &quot;text/html&quot;, value: &quot;&lt;p&gt;html default body&lt;/p&gt;&quot;}]}"},{"ref":"Ada.Email.Quickchart.html","title":"Ada.Email.Quickchart","type":"module","doc":"Minimal DSL and functions to create image charts via https://quickchart.io. Doesn&#39;t support all api options (yet)."},{"ref":"Ada.Email.Quickchart.html#add_dataset/3","title":"Ada.Email.Quickchart.add_dataset/3","type":"function","doc":"Given a chart, add a new dataset, identified by its label and data. iex&gt; Ada.Email.Quickchart.new() ...&gt; |&gt; Ada.Email.Quickchart.add_dataset(&quot;Sales&quot;, [1,2,3]) %Ada.Email.Quickchart{ data: %{datasets: [%{label: &quot;Sales&quot;, data: [1,2,3]}], labels: []}, height: 300, type: &quot;bar&quot;, width: 516 }"},{"ref":"Ada.Email.Quickchart.html#add_labels/2","title":"Ada.Email.Quickchart.add_labels/2","type":"function","doc":"Given a chart, add general labels. iex&gt; Ada.Email.Quickchart.new() ...&gt; |&gt; Ada.Email.Quickchart.add_labels([&quot;May&quot;, &quot;June&quot;]) %Ada.Email.Quickchart{ data: %{datasets: [], labels: [&quot;May&quot;, &quot;June&quot;]}, height: 300, type: &quot;bar&quot;, width: 516 }"},{"ref":"Ada.Email.Quickchart.html#new/1","title":"Ada.Email.Quickchart.new/1","type":"function","doc":"Given a chart type, return a new chart. Defaults to bar iex&gt; Ada.Email.Quickchart.new() %Ada.Email.Quickchart{ data: %{datasets: [], labels: []}, height: 300, type: &quot;bar&quot;, width: 516 } iex&gt; Ada.Email.Quickchart.new(&quot;line&quot;) %Ada.Email.Quickchart{ data: %{datasets: [], labels: []}, height: 300, type: &quot;line&quot;, width: 516 }"},{"ref":"Ada.Email.Quickchart.html#set_dimensions/3","title":"Ada.Email.Quickchart.set_dimensions/3","type":"function","doc":"Given a chart, set its dimensions. iex&gt; Ada.Email.Quickchart.new() ...&gt; |&gt; Ada.Email.Quickchart.set_dimensions(200, 200) %Ada.Email.Quickchart{ data: %{datasets: [], labels: []}, height: 200, type: &quot;bar&quot;, width: 200 }"},{"ref":"Ada.Email.Quickchart.html#to_url/1","title":"Ada.Email.Quickchart.to_url/1","type":"function","doc":"Given a chart, returns its corresponding quickchart url. iex&gt; Ada.Email.Quickchart.new() ...&gt; |&gt; Ada.Email.Quickchart.add_labels([&quot;April&quot;, &quot;May&quot;, &quot;June&quot;]) ...&gt; |&gt; Ada.Email.Quickchart.add_dataset(&quot;Sales&quot;, [1,2,3]) ...&gt; |&gt; Ada.Email.Quickchart.to_url() &quot;https://quickchart.io/chart?c=%7B%27data%27%3A%7B%27datasets%27%3A%5B%7B%27data%27%3A%5B1%2C2%2C3%5D%2C%27label%27%3A%27Sales%27%7D%5D%2C%27labels%27%3A%5B%27April%27%2C%27May%27%2C%27June%27%5D%7D%2C%27type%27%3A%27bar%27%7D&amp;height=300&amp;width=516&quot;"},{"ref":"Ada.Email.Quickchart.html#t:chart_type/0","title":"Ada.Email.Quickchart.chart_type/0","type":"type","doc":""},{"ref":"Ada.Email.Quickchart.html#t:data/0","title":"Ada.Email.Quickchart.data/0","type":"type","doc":""},{"ref":"Ada.Email.Quickchart.html#t:dataset/0","title":"Ada.Email.Quickchart.dataset/0","type":"type","doc":""},{"ref":"Ada.Email.Quickchart.html#t:dimension/0","title":"Ada.Email.Quickchart.dimension/0","type":"type","doc":""},{"ref":"Ada.Email.Quickchart.html#t:label/0","title":"Ada.Email.Quickchart.label/0","type":"type","doc":""},{"ref":"Ada.Email.Quickchart.html#t:t/0","title":"Ada.Email.Quickchart.t/0","type":"type","doc":""},{"ref":"Ada.HTTP.Client.html","title":"Ada.HTTP.Client","type":"module","doc":"Simple http client based on httpc."},{"ref":"Ada.HTTP.Client.html#delete/2","title":"Ada.HTTP.Client.delete/2","type":"function","doc":""},{"ref":"Ada.HTTP.Client.html#get/3","title":"Ada.HTTP.Client.get/3","type":"function","doc":""},{"ref":"Ada.HTTP.Client.html#json_get/3","title":"Ada.HTTP.Client.json_get/3","type":"function","doc":""},{"ref":"Ada.HTTP.Client.html#json_post/3","title":"Ada.HTTP.Client.json_post/3","type":"function","doc":""},{"ref":"Ada.HTTP.Client.html#json_put/3","title":"Ada.HTTP.Client.json_put/3","type":"function","doc":""},{"ref":"Ada.HTTP.Client.html#post/4","title":"Ada.HTTP.Client.post/4","type":"function","doc":""},{"ref":"Ada.HTTP.Client.html#put/4","title":"Ada.HTTP.Client.put/4","type":"function","doc":""},{"ref":"Ada.HTTP.Client.html#t:headers/0","title":"Ada.HTTP.Client.headers/0","type":"type","doc":""},{"ref":"Ada.Workflow.html","title":"Ada.Workflow","type":"behaviour","doc":"The Ada.Workflow module specifies a behaviour which needs to be implemented by all workflows. Core concepts A workflow has a set of requirements which define the parameters required for its correct execution (e.g. it may require a user id). It separates the fetch phase (gathering data) from the format phase (presenting it according to a transport, e.g. email). From idea to implementation One may want to fetch the list of trains starting from a specific location and receive them by email. This translates to a workflow that requires: a user_id (to resolve the email address to send the email to) a location_id (to fetch relevant trainline information) In the fetch phase, the workflow will find user and location in the local repo, then interact with a data source (created separately under the Ada.Source namespace) to retrieve the list of trains. In the format phase, this list of trains, along with any other data coming from the fetch phase, can be formatted according to the transport. It&#39;s important that all side-effectful operations (db queries, http api interactions, current time, etc.) are performed in the fetch phase. This way the format phase can be completely pure, immutable and easy to test. All workflow module names need to start with Ada.Worfklow to be correctly resolved by the runtime. Examples Please see Ada.Worfklow.SendLastFmReport or any other existing workflow module."},{"ref":"Ada.Workflow.html#c:fetch/2","title":"Ada.Workflow.fetch/2","type":"callback","doc":"Given some starting params, return data ready to be formatted."},{"ref":"Ada.Workflow.html#c:format/3","title":"Ada.Workflow.format/3","type":"callback","doc":"Given some data resulting from a fetch/2 call and a transport, return a result compatible with such a transport. For example, for a transport with value :email, a {:ok, %Ada.Email{}} needs to be returned for the workflow to complete successfully."},{"ref":"Ada.Workflow.html#c:human_name/0","title":"Ada.Workflow.human_name/0","type":"callback","doc":"Returns a human readable workflow name"},{"ref":"Ada.Workflow.html#normalize_name/1","title":"Ada.Workflow.normalize_name/1","type":"function","doc":"Normalizes a workflow name to string, avoiding issue in the conversion between a module atom and a string."},{"ref":"Ada.Workflow.html#raw_data/3","title":"Ada.Workflow.raw_data/3","type":"function","doc":"Executes a workflow&#39;s fetch phase, returning the resulting raw data."},{"ref":"Ada.Workflow.html#c:requirements/0","title":"Ada.Workflow.requirements/0","type":"callback","doc":"A map representing the workflow data requirements, keyed by the parameter name (e.g. user_id) and its type (:string). Supports all types handled by Ecto, as under the hood it uses Ecto&#39;s Changeset functions to cast and validate data. See https://hexdocs.pm/ecto/2.2.9/Ecto.Schema.html#module-primitive-types for a list of available types."},{"ref":"Ada.Workflow.html#run/4","title":"Ada.Workflow.run/4","type":"function","doc":"Runs a workflow given its name, starting params, a choice of transport and supporting context. Params are validated and formatted data is checked for compatibility with the chosen transport."},{"ref":"Ada.Workflow.html#transports/0","title":"Ada.Workflow.transports/0","type":"function","doc":"Returns all available transports."},{"ref":"Ada.Workflow.html#valid_name?/1","title":"Ada.Workflow.valid_name?/1","type":"function","doc":"Validates that the passed module name is actually a workflow."},{"ref":"Ada.Workflow.html#validate/2","title":"Ada.Workflow.validate/2","type":"function","doc":"Validates a map of params according to a workflows&#39;s requirements specification."},{"ref":"Ada.Workflow.html#t:ctx/0","title":"Ada.Workflow.ctx/0","type":"type","doc":""},{"ref":"Ada.Workflow.html#t:raw_data/0","title":"Ada.Workflow.raw_data/0","type":"type","doc":""},{"ref":"Ada.Workflow.html#t:raw_data_result/0","title":"Ada.Workflow.raw_data_result/0","type":"type","doc":""},{"ref":"Ada.Workflow.html#t:requirements/0","title":"Ada.Workflow.requirements/0","type":"type","doc":""},{"ref":"Ada.Workflow.html#t:run_result/0","title":"Ada.Workflow.run_result/0","type":"type","doc":""},{"ref":"Ada.Workflow.html#t:t/0","title":"Ada.Workflow.t/0","type":"type","doc":""},{"ref":"Ada.Workflow.html#t:transport/0","title":"Ada.Workflow.transport/0","type":"type","doc":""},{"ref":"Ada.Workflow.html#t:validation_errors/0","title":"Ada.Workflow.validation_errors/0","type":"type","doc":""},{"ref":"Ada.CLI.FishCompletion.html","title":"Ada.CLI.FishCompletion","type":"module","doc":"Provides autocomplete settings for the Fish shell. Kudos to https://gist.github.com/hasit/7f80cfee0d2cc789b75f4aaea40f37e0#file-buffalo-fish for the extensive examples."},{"ref":"Ada.CLI.FishCompletion.html#render/0","title":"Ada.CLI.FishCompletion.render/0","type":"function","doc":"Returns a string containing autocomplete directives extracted from the Ada.CLI module layout."},{"ref":"Ada.CLI.Helpers.html","title":"Ada.CLI.Helpers","type":"module","doc":"Provides helper functions to ease the composition of CLI tasks."},{"ref":"Ada.CLI.Helpers.html#connect!/2","title":"Ada.CLI.Helpers.connect!/2","type":"function","doc":"Uses the erlang distribution to connect the CLI node to the device node."},{"ref":"Ada.CLI.Helpers.html#ensure_location_dependencies!/0","title":"Ada.CLI.Helpers.ensure_location_dependencies!/0","type":"function","doc":"Only working on Mac, checks for the dependencies needed to infer the current location of the machine from the command line."},{"ref":"Ada.CLI.Helpers.html#get_current_location_data/0","title":"Ada.CLI.Helpers.get_current_location_data/0","type":"function","doc":"Only working on Mac, returns the current location data."},{"ref":"Ada.CLI.Markup.html","title":"Ada.CLI.Markup","type":"module","doc":"This module defines semantic helpers that can be used to format CLI-based reports. It includes (among other things) titles, headings, paragraphs (with support for wrapping text), lists and bars. The recommended usage pattern is to build lists of elements and then pass them to IO.iodata_to_binary/1 for conversion to a printable binary."},{"ref":"Ada.CLI.Markup.html#bar/1","title":"Ada.CLI.Markup.bar/1","type":"function","doc":"Returns a bar of the specified length."},{"ref":"Ada.CLI.Markup.html#break/0","title":"Ada.CLI.Markup.break/0","type":"function","doc":"New line separator"},{"ref":"Ada.CLI.Markup.html#dash/0","title":"Ada.CLI.Markup.dash/0","type":"function","doc":"Returns a dash, followed by a space"},{"ref":"Ada.CLI.Markup.html#double_title/3","title":"Ada.CLI.Markup.double_title/3","type":"function","doc":"Separates left text and right text with a continuous line, pushing them to the left and right border of the page. The left text is wrapped in red. E.g. Left ———————————————————————————————— Right"},{"ref":"Ada.CLI.Markup.html#ellipsis/2","title":"Ada.CLI.Markup.ellipsis/2","type":"function","doc":"Truncates the text at the specified length, appending an ellipsis"},{"ref":"Ada.CLI.Markup.html#emdash/0","title":"Ada.CLI.Markup.emdash/0","type":"function","doc":"Returns an emphasis dash, wrapped in spaces"},{"ref":"Ada.CLI.Markup.html#h1/1","title":"Ada.CLI.Markup.h1/1","type":"function","doc":"Returns the text wrappend on the left, in primary color and adds a break at the end."},{"ref":"Ada.CLI.Markup.html#h2/1","title":"Ada.CLI.Markup.h2/1","type":"function","doc":"Returns the text wrappend on the left, in secondary color and adds a break at the end."},{"ref":"Ada.CLI.Markup.html#h3/1","title":"Ada.CLI.Markup.h3/1","type":"function","doc":"Returns the text wrappend on the left, in tertiary color and adds a break at the end."},{"ref":"Ada.CLI.Markup.html#left_pad/0","title":"Ada.CLI.Markup.left_pad/0","type":"function","doc":"Left padding"},{"ref":"Ada.CLI.Markup.html#list_item/2","title":"Ada.CLI.Markup.list_item/2","type":"function","doc":"Returns a list item, i.e. a definition with a name (wrapped in secondary colour) and a value. Values are pretty printed according to their type: maps, keyword lists and lists of tuples get expanded one pair per line, with the pair elements separated by a : lists get expanded one element per line other values are printed on one line beside the name."},{"ref":"Ada.CLI.Markup.html#p/2","title":"Ada.CLI.Markup.p/2","type":"function","doc":"Returns the text, wrapped at the specified length. All lines are padded on the left and it adds a break at the end."},{"ref":"Ada.CLI.Markup.html#primary/1","title":"Ada.CLI.Markup.primary/1","type":"function","doc":"Wraps contents in primary color"},{"ref":"Ada.CLI.Markup.html#secondary/1","title":"Ada.CLI.Markup.secondary/1","type":"function","doc":"Wraps contents in secondary color"},{"ref":"Ada.CLI.Markup.html#space/0","title":"Ada.CLI.Markup.space/0","type":"function","doc":"Space separator"},{"ref":"Ada.CLI.Markup.html#tertiary/1","title":"Ada.CLI.Markup.tertiary/1","type":"function","doc":"Wraps contents in tertiary color"},{"ref":"Ada.CLI.Markup.html#title/1","title":"Ada.CLI.Markup.title/1","type":"function","doc":"Returns the text padded on the left, in red color and adds a break at the end."},{"ref":"Logger.Backends.Telegraf.html","title":"Logger.Backends.Telegraf","type":"module","doc":"Telegraf compatible, syslog formatted Logger backend. Derived from smpallen99/syslog: Elixir logger syslog backend at https://github.com/smpallen99/syslog."},{"ref":"Logger.Backends.Telegraf.html#handle_call/2","title":"Logger.Backends.Telegraf.handle_call/2","type":"function","doc":"Callback implementation for c::gen_event.handle_call/2."},{"ref":"Logger.Backends.Telegraf.html#handle_event/2","title":"Logger.Backends.Telegraf.handle_event/2","type":"function","doc":"Callback implementation for c::gen_event.handle_event/2."},{"ref":"Logger.Backends.Telegraf.html#init/1","title":"Logger.Backends.Telegraf.init/1","type":"function","doc":"Callback implementation for c::gen_event.init/1."},{"ref":"Ada.PubSub.html","title":"Ada.PubSub","type":"module","doc":"Provides a single-node pub-sub infrastructure on top of Registry. It needs to be added to the application supervision tree: children = [ Ada.PubSub ] See subscribe/1 and publish/2 for usage details."},{"ref":"Ada.PubSub.html#publish/2","title":"Ada.PubSub.publish/2","type":"function","doc":"Publishes a message for a given topic."},{"ref":"Ada.PubSub.html#subscribe/1","title":"Ada.PubSub.subscribe/1","type":"function","doc":"Subscribes a process to a topic. The process will receive messages in the shape of {:Ada.PubSub.Broadcast, topic, message}."},{"ref":"readme.html","title":"Ada","type":"extras","doc":"Ada Ada is personal assistant designed to run on the Pimoroni Scroll Bot (i.e. a Raspberry Pi Zero W and a Scroll pHAT HD). It’s powered by Nerves Project and Elixir. ."},{"ref":"readme.html#features","title":"Ada - Features","type":"extras","doc":"Ada fits a specific use case: a small device, using little energy, that helps me with things I do on a daily basis. Hardware-wise, the Pimoroni kit is a perfect fit: it looks cool, has a low-fi screen that I can use to report basic useful information even in bright light conditions and I can pack it with me when I travel. At this point Ada support these workflows: Email me Guardian News about a specific topic (via theguardian / open platform) Email me the weather forecast for the day at a specific location (via Dark Sky) Email me what I’ve listened to in the last day/week (via Last.fm) Workflows can be scheduled at hourly, daily or weekly intervals, with configurable parameters like locations or email recipients. The display is used primarily as a digital clock, but it can display if one or more scheduled tasks are running. Ada’s timezone can be configured and its clock is synchronised automatically. Ada’s default email adapter is Sendgrid. Ada’s default backup strategy uses Dropbox via a custom app."},{"ref":"readme.html#interaction-modes","title":"Ada - Interaction modes","type":"extras","doc":"Ada can be controlled by a command line UI (CLI) and an HTTP API. CLI interaction The CLI can be setup by following these instructions. To function, it requires the ability to connect to the running device via the Erlang distribution. By default, it will assume that the target device is available at ada.local. Running ./ada will show a list of available commands. If you happen to use the Fish shell, you can run ./ada fish_autocomplete | source to load basic completions for the current shell (pull requests are welcome to support other shells!). Generally speaking, with the CLI you can: control the display brightness manage device data (users, locations, tasks) manage device preferences run or preview tasks backup the database with the active backup strategy pull the device database to a local file restore the device database from a local file As an example, we can add a new user and setup a news digest about UK news, sent every day at 9am: $ ./ada create_user mary mary@example.com Created User with ID 3 $ ./ada create_scheduled_task send_news_by_tag daily:9 --user_id 3 --tag &#39;uk/uk&#39; Created scheduled_task with ID 9 HTTP interaction HTTP api documentation is available at http://ada.local/swagger-ui."},{"ref":"readme.html#setup","title":"Ada - Setup","type":"extras","doc":"First of all, we need working installations of Elixir and Erlang. The recommended way to achieve this is via asdf. Once it&#39;s installed and working, you can run asdf install from the project root to install the correct versions required by Ada (see the .tool-versions file for details). Next, make sure you setup the required environment variables as detailed in .envrc.example. We recommend using a program such as direnv to make this process automatic. To support over-the-air updates, the firmware requires an ssh public key at ~/.ssh/id_rsa.pub. This is not needed unless you try to produce a firmware file. Once they&#39;re setup, you can run make dev.setup to install required tools and dependencies. Note that this will not install system-wide dependencies which are required to burn the Ada firmware to a card (see the MacOS and Linux sections at https://hexdocs.pm/nerves/installation.html#content for details). At this stage, you should be able to perform the most common tasks: Running tests You can run make host.test. Build the CLI You can run make host.cli, which will leave you with the ada executable in the current directory. You can move it anywhere, but to function properly it requires a compatible version of Erlang available globally. You can checkout the asdf documentation to configure that. Run dialyzer You can run make host.dialyzer to perform a static analysis of the source code to find type inconsistencies. The first time you run it might take a while, it will be considerably faster after that. Build docs You can run make host.docs. Key parts of the source are documented, so this should help in case you feel like contributing. Open a local iex session You can run make host.shell. Produce a firmware You can run make rpi0.firmware to produce a firmware file. Running make rpi0.burn will produce a file and try to burn it to a SD/MicroSD card if possible. Update the device on the fly You can run make rpi0.push to perform a over-the-air device update. Remote shell to the running device You can run make rpi0.ssh."},{"ref":"readme.html#data-backups","title":"Ada - Data backups","type":"extras","doc":"Ada is capable of backing up its own db file at 3am every night. To do that, it uses a configured backup strategy (with Dropbox being the one currently implemented). To activate it, it&#39;s enough to define a DROPBOX_API_TOKEN env variable (the token can be created at https://www.dropbox.com/developers/apps)."},{"ref":"readme.html#commit-legend","title":"Ada - Commit legend","type":"extras","doc":"[F] Feature [C] Chore [B] Bugfix [D] Documentation [R] Refactor"}]