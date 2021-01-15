<script>
  export let chosenFields = [];

  import fieldMap from "./fieldMap";
  import { asString } from "./sampleEmail";
  import sendEmail from "@salesforce/apex/FormAPI.sendEmail";
  //import { renderMail } from "svelte-mail";

  // async function showMailText(){
  //   const {html, text} = await renderMail()
  // }
  let el;
  let send = async () => {
    await sendEmail({
      htmlString: asString.replace(
        "{{REPLACE_WITH_FORM}}",
        el.innerHTML.replaceAll('c-app_app=""', "")
      ),
    });
    console.log("sent");
  };
</script>

<div bind:this={el}>
  <form
    action="https://sandbox-form-handler-developer-edition.cs77.force.com/services/apexrest/form/"
    method="get"
  >
    {#each chosenFields as chosen}
      <div>
        <label>
          {chosen.label}
          <input
            type={fieldMap[chosen.dataType]}
            placeholder={chosen.label}
            name={chosen.apiName}
          />
        </label>
      </div>
    {/each}
    <button type="submit">Submit</button>
  </form>
  <button type="button" on:click={send}>Send Email to Myles</button>
</div>

<style>
  form {
    text-align: left;
  }
  label {
    display: block;
  }
  input {
    padding: 10px;
    border: 1px solid #ccc;
    border-radius: 5px;
    display: block;
  }
</style>
