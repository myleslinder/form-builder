<script>
  export let info;

  import Preview from "./Preview.svelte";
  import fieldMap from "./fieldMap";
  //import describeObjectFields from "@salesforce/apex/OrgAPI.describeObjectFields";
  import { onMount } from "svelte";

  let fields;
  let chosenFields = [];
  let selectedField;

  let addField = () => {
    chosenFields = [...chosenFields, selectedField];
    fields = fields.map((f) =>
      f.apiName === selectedField.apiName ? { ...f, chosen: true } : f
    );
  };

  onMount(async () => {
    fields = Object.keys(info.fields)
      .filter(
        (f) => fieldMap[info.fields[f].dataType] && info.fields[f].updateable
      )
      .map((f) => ({ ...info.fields[f], chosen: false }));
    console.log(fields);
  });
  // use the await describeObjectFields() to bulk get the picklist fields
</script>

<main class="slds-size_full">
  <div class="row slds-grid">
    <div class="source-column">
      <div>
        {#if fields}
          <select bind:value={selectedField}>
            {#each fields as field (field.apiName)}
              <option value={field} disabled={field.chosen}
                >{field.label}</option
              >
            {/each}
          </select>
        {/if}
      </div>

      <button class="slds-button slds-button_brand" on:click={addField}>
        Add Field
      </button>
    </div>
    <div class="input-column">
      <input type="text" value="hi there" />
    </div>
  </div>
  {#if chosenFields.length}
    <Preview {chosenFields} />
  {/if}
</main>

<style>
  main {
    background: #fff;
    text-align: center;
    padding: 1em;
    min-height: 100vh;
    margin: 0 auto;
  }
</style>
