// Include this line at the top of your scripts
// See the documentation for more information:
//         https://lab.florianschwarz.net/PennController/wiki/documentation/

var shuffleSequence = seq('consent', 'Instruction', 'instruction_check', shuffle(rshuffle(('prepositional'), ('particle')), randomize('catch'), randomize('filler')), 'demographics', 'feedback', 'send', 'debrief', 'exit')

PennController.ResetPrefix(null)

PennController.SetCounter('consent')

var uniqueid = Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15)

PennController.Template(PennController.GetTable('group_instructions.csv'),
  row => PennController('Instruction',
    newHtml('Instruction', row.Instruction)
      .print()
    ,
    newVar('Link', "\u003Cp style='text-align:right;margin-bottom:2em'\u003E\u003Csmall\u003E\u003Ca href='http://spellout.net/ibexexps/parkerrobbins/" + row.Link + "' target='\u005Fblank'\u003EInstructions\u003C/a\u003E\u003C/small\u003E\u003C/p\u003E")
      .settings.global()
    ,
    newText('after', "\u003Cp style='width: 40em; margin-top:-2em'\u003E The instructions will remain available at the top of the page for your reference. \u003Cbr\u003E \u003Cbr\u003EClicking on the \u201CInstructions\u201D link will open the instructions in a new tab. \u003Cbr\u003E \u003Cbr\u003EOn the next page, you will be asked a question to ensure you understand the instructions. \u003Cbr\u003E \u003Cbr\u003E When you are ready to continue, click \u201CNext\u201D. \u003C/p\u003E")
      .print()
    ,
    newButton('start', 'Next')
      .print()
      .wait()

  )
    .log('Instruction', row.Group)
)

PennController('exit',
  newHtml('exit', 'exit.html')
    .print()
  ,
  newButton('okay', 'OK')
    .print()
    .wait()
)

PennController('consent',
  newHtml('consent form', 'consent.html')
    .print()
  ,
  newButton('accept', 'Accept')
    .print()
    .wait()
)

PennController('demographics',
  newHtml('demographics form', 'demographic_survey.html')
    .settings.log()
    .print()
  ,
  newButton('send', 'Send')
    .print()
    .wait()
)

PennController('debrief',
  newHtml('copy_paste', 'copy_paste.html')
    .print()
  ,
  newText('subjectid', uniqueid)
    .settings.bold()
    .settings.center()
    .print()
  ,
  newHtml('debrief form', 'debrief.html')
    .print()
  ,
  newButton('finish', 'Finish')
    .print()
    .wait()
)
PennController('feedback',
  newTextInput('feedback', 'You are welcome to leave any feedback you have here.')
    .settings.log()
    .settings.lines(0)
    .print()
  ,
  newButton('send', 'Send')
    .print()
    .wait()
)
  .log('uniqueid', uniqueid)

PennController.Template(PennController.GetTable('all_stim_final.csv').filter('type', 'filler'),
  row => PennController('filler',
    newText('link', getVar('Link'))
      .print()
    ,
    newText('sentence1', '\u25ba\u2003' + row.VersionA)
      .print()
    ,
    newText('sentence2', '\u25ba\u2003' + row.VersionB)
      .print()
    ,
    newSelector('trial1')
      .settings.log()
      .settings.add(getText('sentence1'), getText('sentence2'))
      .shuffle()
      .wait()
    ,
    newButton('validation', 'Validate')
      .print()
      .wait(getSelector('trial1').test.selected())

  )
    .log('sentence1', row.VersionA)
)

PennController.Template(PennController.GetTable('all_stim_final.csv').filter('type', 'prepositional'),
  row => PennController('prepositional',
    newText('link', getVar('Link'))
      .print()
    ,
    newText('sentence1', '\u25ba\u2003' + row.VersionA)
      .print()
    ,
    newText('sentence2', '\u25ba\u2003' + row.VersionB)
      .print()
    ,
    newSelector('trial1')
      .settings.log()
      .settings.add(getText('sentence1'), getText('sentence2'))
      .shuffle()
      .wait()
    ,
    newButton('validation', 'Validate')
      .print()
      .wait(getSelector('trial1').test.selected()))
    .log('sentence1', row.VersionA)
)

PennController.Template(PennController.GetTable('all_stim_final.csv').filter('type', 'particle'),
  row => PennController('particle',
    newText('link', getVar('Link'))
      .print()
    ,
    newText('sentence1', '\u25ba\u2003' + row.VersionA)
      .print()
    ,
    newText('sentence2', '\u25ba\u2003' + row.VersionB)
      .print()
    ,
    newSelector('trial1')
      .settings.log()
      .settings.add(getText('sentence1'), getText('sentence2'))
      .shuffle()
      .wait()
    ,
    newButton('validation', 'Validate')
      .print()
      .wait(getSelector('trial1').test.selected())
  )
    .log('sentence1', row.VersionA)
)

PennController('instruction_check',
  newText('link', '')
    .settings.text(getVar('Link'))
    .print()
  ,
  newText('question1', "\u003Cp style='width: 45em; margin-top:-2em'\u003E For this survey, it is very important that you understand the instructions. \u003Cbr\u003EPlease select the answer that best describes what you will be doing in this task and then click \u201CStart the experiment!\u201D \u003Cbr\u003EIf you would like to review before you answer, click on the \u201CInstructions\u201D link above.\u003C/p\u003E")
    .settings.italic()
    .settings.bold()
    .print()
  ,
  newText('choice1', '\u25ba\u2003' + 'Rating sentences on a scale from 1 to 7.')
    .print()
  ,
  newText('choice2', '\u25ba\u2003' + 'Selecting one of two sentences according to the instructions on the previous page.')
    .print()
  ,
  newText('choice3', '\u25ba\u2003' + 'Reading sentences and then answering questions about their content.')
    .print()
  ,
  newText('choice4', '\u25ba\u2003' + 'Attempting to find the missing word in each sentence.')
    .print()
  ,
  newSelector('instruction_verification')
    .settings.log()
    .settings.add(getText('choice1'), getText('choice2'), getText('choice3'), getText('choice4'))
    .shuffle()
    .wait()
  ,
  newButton('validation', 'Start the experiment!')
    .print()
    .wait(getSelector('instruction_verification').test.selected())
  ,
  getButton('validation')
    .test.clicked()
    .success(
      getSelector('instruction_verification')
        .test.selected(getText('choice2'))
        .failure(
          getText('question1')
            .remove()
          ,
          getText('choice1')
            .remove()
          ,
          getText('choice2')
            .remove()
          ,
          getText('choice3')
            .remove()
          ,
          getText('choice4')
            .remove()
          ,
          getText('link')
            .remove()
          ,
          newText('wrong', 'Sorry, you failed the instruction comprehension check. Please exit the experiment.')
            .print()
          ,
          getButton('validation')
            .settings.hidden()
            .wait()
        )
    )
)
PennController.Template(PennController.GetTable('all_stim_final.csv').filter('type', 'catch'),
  row => PennController('catch',
    newText('link', getVar('Link'))
      .print()
    ,
    newText('sentence1', '\u25ba\u2003' + row.VersionA)
      .print()
    ,
    newText('sentence2', '\u25ba\u2003' + row.VersionB)
      .print()
    ,
    newSelector('trial1')
      .settings.log()
      .settings.add(getText('sentence1'), getText('sentence2'))
      .shuffle()
      .wait()
    ,
    newButton('validation', 'Validate')
      .print()
      .wait(getSelector('trial1').test.selected())
    ,
    getButton('validation')
      .test.clicked()
      .success(
        getSelector('trial1')
          .test.selected(getText('sentence1'))
          .failure(
            getText('sentence1')
              .remove()
            ,
            getText('sentence2')
              .remove()
            ,
            getText('link')
              .remove()
            ,
            newText('wrong', 'Sorry, you failed this attention check. Please exit the experiment.')
              .print()
            ,
            getButton('validation')
              .settings.hidden()
              .wait()

          )
      )

  )
    .log('sentence1', row.VersionA)
)

PennController.SendResults('send')
