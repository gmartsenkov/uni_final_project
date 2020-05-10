import jQuery from 'jquery';

export default {
  initSelect2() {
    let hook = this,
      $select = jQuery(hook.el).find("select#autocompleteAuthor");

    $select.select2({
      minimumInputLength: 3,
      theme: 'bootstrap4',
      ajax: {
        url: "/users/autocomplete",
        delay: 250,
        data: (params) => {
          return { query: params.term }
        },
        processResults: (data) => {
          return {
            results: data.map(user => {
              return { id: user.id, text: user.name }
            })
          }
        }
      },
    }).on("select2:select", (e) => hook.selected($select, hook, e))

    return $select;
  },

  mounted() {
    this.initSelect2();
  },

  selected($select, hook, event) {
    hook.pushEventTo("#author-multiselect", "add_author", event.params.data);
    $select.val(null).trigger('change');
  }
}
