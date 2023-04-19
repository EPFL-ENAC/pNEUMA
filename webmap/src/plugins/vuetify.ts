import { createVuetify } from 'vuetify'
import { aliases, mdi } from 'vuetify/iconsets/mdi-svg'
import colors from 'vuetify/lib/util/colors'
import 'vuetify/styles'

export default createVuetify({
  icons: {
    defaultSet: 'mdi',
    aliases,
    sets: {
      mdi
    }
  },
  theme: {
    themes: {
      light: {
        colors: {
          primary: colors.shades.black,
          secondary: colors.blue.base
        }
      }
    }
  }
})
