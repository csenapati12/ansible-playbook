when condition used skip some steps/modules, its similar to if condtion

Tags are used when,
If you have a large playbook it may become useful to be able to run a specific part of the configuration without running the whole playbook.
Buy default all the tags used to executed

calling ways for the tags is as below
ansible-playbook play.yml(playbookname) --tags "tagname1, tagname2"

you can skip some tags as below and rest of the task will be executed except the skipped one
ansible-playbook example.yml --skip-tags "tag1"

Special tag(always)

always

There is a special always tag that will always run a task

never


Another special tag is never, which will prevent a task from running unless a tag is specifically requested.

//adding some comment


ex:
 - debug:
        msg: "Always runs"
      tags:
        - always
testing log
distributed 12 March 2021
